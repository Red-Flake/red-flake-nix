"""Stellaris desktop daemon: Hyprland window actions and a Canonical DBusMenu registrar.

Usage:
  stellaris-desktop serve              run the session daemon
  stellaris-desktop watch              stream state as JSON lines (Noctalia app-menu plugin)
  stellaris-desktop action NAME [ADDR] window action on ADDR or the focused window
  stellaris-desktop send JSON          raw request, e.g. menu actions from the plugin

Menus are matched to windows by exact Wayland/X11 metadata, falling back to PID
only when the association is unambiguous. No application-provided text is ever
evaluated as shell or Lua code.
"""
import asyncio
import json
import os
import re
import configparser
import sys
import time
from pathlib import Path
from dbus_next import Message, MessageType, Variant, NameFlag, RequestNameReply
from dbus_next.aio import MessageBus

INTERFACE = "com.canonical.AppMenu.Registrar"
PATH = "/com/canonical/AppMenu/Registrar"
MENU = "com.canonical.dbusmenu"
XML = '''<node><interface name="com.canonical.AppMenu.Registrar">
<method name="RegisterWindow"><arg type="u" direction="in"/><arg type="o" direction="in"/></method>
<method name="UnregisterWindow"><arg type="u" direction="in"/></method>
<method name="GetMenuForWindow"><arg type="u" direction="in"/><arg type="s" direction="out"/><arg type="o" direction="out"/></method>
<method name="GetMenus"><arg type="a(uso)" direction="out"/></method>
<signal name="WindowRegistered"><arg type="u"/><arg type="s"/><arg type="o"/></signal>
<signal name="WindowUnregistered"><arg type="u"/></signal>
</interface></node>'''


def unpack(value):
    if isinstance(value, Variant):
        return unpack(value.value)
    if isinstance(value, dict):
        return {k: unpack(v) for k, v in value.items()}
    if isinstance(value, (tuple, list)):
        return [unpack(v) for v in value]
    return value


def menu_tree(layout):
    item_id, props, children = unpack(layout)
    return {"id": item_id, "text": props.get("label", "").replace("_", ""),
            "enabled": props.get("enabled", True), "visible": props.get("visible", True),
            "separator": props.get("type") == "separator",
            "submenu": props.get("children-display") == "submenu",
            "checked": props.get("toggle-state", 0) == 1,
            "children": [menu_tree(c) for c in children if unpack(c)[1].get("visible", True)]}


def window_expression(action, address, workspace=1):
    if not re.fullmatch(r"0x[0-9a-fA-F]+", address):
        raise ValueError("Invalid window address")
    window = 'window="address:' + address + '"'
    expressions = {
        "close": 'hl.dsp.window.close({' + window + '})',
        "maximize": 'hl.dsp.window.fullscreen({mode="maximized",' + window + '})',
        "tile": 'hl.dsp.window.float({action="toggle",' + window + '})',
        "minimize": 'hl.dsp.window.move({workspace="special:minimized",follow=false,' + window + '})',
        "restore": 'hl.dsp.window.move({workspace=' + str(max(1, int(workspace))) + ',follow=false,' + window + '})',
        "focus": 'hl.dsp.focus({' + window + '})',
    }
    return expressions[action]


class Bridge:
    def __init__(self):
        self.registrations = {}
        self.clients = []
        self.active = {}
        self.workspace = 1
        self.menu_key = None
        self.tree = []
        self.refresh_menu = True
        self.error = ""
        self.bus = None
        self.last_state = None
        self.wake = asyncio.Event()
        self.action_lock = asyncio.Lock()
        # The event loop only holds weak references to tasks.
        self.tasks = set()
        self.socket = os.path.join(os.environ["XDG_RUNTIME_DIR"], "hypr",
                                   os.environ["HYPRLAND_INSTANCE_SIGNATURE"], ".socket.sock")
        self.restore_file = Path(self.socket).with_name("stellaris-restore.json")
        self.control = control_socket()
        self.watchers = set()
        self.names = {}
        self.names_indexed = 0.0
        try:
            self.saved = json.loads(self.restore_file.read_text())
        except (OSError, ValueError):
            self.saved = {}

    def index_desktop_entries(self):
        """Map lower-case desktop IDs, their last dotted part and StartupWMClass to Name."""
        dirs = [os.environ.get("XDG_DATA_HOME", os.path.expanduser("~/.local/share"))]
        dirs += os.environ.get("XDG_DATA_DIRS", "/run/current-system/sw/share").split(":")
        names = {}
        for directory in reversed(dirs):
            for entry in Path(directory, "applications").glob("*.desktop"):
                parser = configparser.ConfigParser(interpolation=None, strict=False)
                try:
                    parser.read(entry, encoding="utf-8")
                    section = parser["Desktop Entry"]
                except (configparser.Error, KeyError, OSError, UnicodeDecodeError):
                    continue
                name = section.get("Name")
                if not name:
                    continue
                stem = entry.name.removesuffix(".desktop").lower()
                for key in (stem, stem.rsplit(".", 1)[-1], section.get("StartupWMClass", "").lower()):
                    if key:
                        names[key] = name
        self.names, self.names_indexed = names, time.monotonic()

    def app_name(self, window_class):
        key = (window_class or "").lower()
        if not key:
            return ""
        if key not in self.names and time.monotonic() - self.names_indexed > 30:
            self.index_desktop_entries()
        return self.names.get(key) or self.names.get(key.rsplit(".", 1)[-1]) or window_class

    def publish(self, encoded):
        for writer in list(self.watchers):
            try:
                writer.write(encoded.encode() + b"\n")
            except (OSError, RuntimeError):
                self.watchers.discard(writer)

    def save(self):
        temporary = self.restore_file.with_suffix(".tmp")
        temporary.write_text(json.dumps(self.saved))
        temporary.replace(self.restore_file)

    async def hypr(self, command):
        async def request():
            reader, writer = await asyncio.open_unix_connection(self.socket)
            try:
                writer.write(command.encode())
                await writer.drain()
                return (await reader.read()).decode()
            finally:
                writer.close()
                await writer.wait_closed()
        return await asyncio.wait_for(request(), 2)

    async def call(self, destination, path, interface, member, signature="", body=None):
        reply = await asyncio.wait_for(self.bus.call(Message(
            destination=destination, path=path, interface=interface,
            member=member, signature=signature, body=body or [])), 2)
        if reply.message_type == MessageType.ERROR:
            raise RuntimeError(reply.error_name)
        return reply.body

    def spawn(self, coroutine):
        task = asyncio.create_task(coroutine)
        self.tasks.add(task)
        task.add_done_callback(self.tasks.discard)

    def signal(self, member, signature, body):
        self.bus.send(Message.new_signal(PATH, INTERFACE, member, signature, body))

    def receive(self, message):
        if message.message_type == MessageType.SIGNAL:
            if message.member == "NameOwnerChanged":
                name, _, owner = message.body
                if not owner:
                    for key, entry in list(self.registrations.items()):
                        if entry[0] == name:
                            del self.registrations[key]
                            self.signal("WindowUnregistered", "u", [key[1]])
            elif message.interface == MENU:
                self.refresh_menu = True
            return
        if message.message_type != MessageType.METHOD_CALL or message.path != PATH:
            return
        if message.interface == "org.freedesktop.DBus.Introspectable":
            self.bus.send(Message.new_method_return(message, "s", [XML]))
            return True
        if message.interface == INTERFACE:
            self.spawn(self.registrar(message))
            return True

    async def registrar(self, msg):
        try:
            if msg.member == "RegisterWindow":
                wid, path = msg.body
                pid = (await self.call("org.freedesktop.DBus", "/org/freedesktop/DBus",
                       "org.freedesktop.DBus", "GetConnectionUnixProcessID", "s", [msg.sender]))[0]
                self.registrations[(msg.sender, wid)] = (msg.sender, path, pid)
                self.signal("WindowRegistered", "uso", [wid, msg.sender, path])
                reply = Message.new_method_return(msg)
                self.refresh_menu = True
            elif msg.member == "UnregisterWindow":
                wid = msg.body[0]
                if (msg.sender, wid) in self.registrations:
                    del self.registrations[(msg.sender, wid)]
                    self.signal("WindowUnregistered", "u", [wid])
                reply = Message.new_method_return(msg)
            elif msg.member == "GetMenuForWindow":
                matches = [v for (_, wid), v in self.registrations.items() if wid == msg.body[0]]
                entry = matches[0] if len(matches) == 1 else ("", "/", 0)
                reply = Message.new_method_return(msg, "so", list(entry[:2]))
            elif msg.member == "GetMenus":
                reply = Message.new_method_return(msg, "a(uso)", [
                    [[wid, v[0], v[1]] for (_, wid), v in self.registrations.items()]])
            else:
                reply = Message.new_error(msg, "org.freedesktop.DBus.Error.UnknownMethod", msg.member)
            self.bus.send(reply)
        except Exception as exc:
            self.bus.send(Message.new_error(msg, "org.freedesktop.DBus.Error.Failed", str(exc)))

    async def update(self):
        clients, active, workspace, metadata = await asyncio.gather(
            self.hypr("j/clients"), self.hypr("j/activewindow"), self.hypr("j/activeworkspace"),
            self.hypr("j/stellaris:windows"))
        self.clients, self.active = json.loads(clients), json.loads(active)
        self.workspace = json.loads(workspace).get("id", 1)
        pid = self.active.get("pid", -1)
        matches = {entry[:2] for entry in self.registrations.values() if entry[2] == pid}
        try:
            details = json.loads(metadata).get(self.active.get("address", ""), {})
        except (ValueError, AttributeError):
            details = {}
        exact = {entry[:2] for (_, wid), entry in self.registrations.items()
                 if wid == details.get("xid") and entry[2] == pid}
        key = tuple(details["menu"]) if details.get("menu") else (
            next(iter(exact)) if len(exact) == 1 else next(iter(matches)) if len(matches) == 1 else None)
        live = {c["address"] for c in self.clients}
        stale = set(self.saved) - live
        if stale:
            for address in stale:
                del self.saved[address]
            self.save()
        if key != self.menu_key:
            self.menu_key, self.tree, self.refresh_menu = key, [], True
        if key and self.refresh_menu:
            self.refresh_menu = False
            try:
                result = await self.call(*key, MENU, "GetLayout", "iias", [0, -1, []])
                self.tree = menu_tree(result[1])["children"]
            except Exception:
                self.tree = []
        active = {k: self.active.get(k) for k in ("address", "class", "title")}
        state = {"app": self.app_name(self.active.get("class")), "active": active,
                 "menuKey": list(key) if key else [], "menus": self.tree, "error": self.error}
        encoded = json.dumps(state)
        if encoded != self.last_state:
            self.last_state = encoded
            self.publish(encoded)

    async def action(self, request):
        async with self.action_lock:
            await self.perform_action(request)
            self.wake.set()

    async def perform_action(self, request):
        action = request.get("action")
        if action in ("menu-open", "menu-click"):
            key = tuple(request.get("key", []))
            if key != self.menu_key or not key:
                return
            item = int(request["id"])
            if action == "menu-open":
                await self.call(*key, MENU, "AboutToShow", "i", [item])
                self.refresh_menu = True
            else:
                await self.call(*key, MENU, "Event", "isvu", [item, "clicked", Variant("i", 0), 0])
            return
        if action in ("goto-workspace", "next-workspace", "previous-workspace"):
            monitor = request.get("monitor", "")
            if monitor:
                if not re.fullmatch(r"[A-Za-z0-9._-]+", monitor):
                    raise ValueError("Invalid monitor")
                await self.hypr('dispatch hl.dsp.focus({monitor="' + monitor + '"})')
            if action == "goto-workspace":
                target = int(request["workspace"])
                if not 1 <= target <= 99:
                    raise ValueError("Invalid workspace")
            else:
                target = '"r+1"' if action == "next-workspace" else '"r-1"'
            result = await self.hypr("dispatch hl.dsp.focus({workspace=" + str(target) + "})")
            if result.strip() != "ok":
                raise RuntimeError(result)
            return
        address = request.get("address")
        if not address:
            # A titlebar click may focus a new window before the next state update.
            address = json.loads(await self.hypr("j/activewindow")).get("address", "")
        client = next((c for c in self.clients if c["address"] == address), None)
        if client is None:
            return
        hidden = client.get("workspace", {}).get("name") == "special:minimized"
        if action == "minimize":
            if hidden:
                return
            self.saved.setdefault(address, {})["workspace"] = client.get("workspace", {}).get("id", self.workspace)
            self.save()
        if action in ("activate", "restore"):
            if hidden:
                workspace = self.saved.get(address, {}).pop("workspace", self.workspace)
                await self.hypr("dispatch " + window_expression("restore", address, workspace))
                self.save()
            action = "focus"
        if action.startswith("workspace-"):
            workspace = int(action.removeprefix("workspace-"))
            if not 1 <= workspace <= 9:
                raise ValueError("Invalid workspace")
            result = await self.hypr("dispatch " + window_expression("restore", address, workspace))
            if result.strip() != "ok":
                raise RuntimeError(result)
            return
        if action == "maximize" and (client.get("floating") or client.get("fullscreen")):
            await self.toggle_maximize(client)
            return
        if action in ("left", "right"):
            area = await self.work_area(client)
            if area is None:
                return
            x, y, width, height = area
            half = width // 2
            await self.place(address, x + (half if action == "right" else 0), y, half, height)
            return
        result = await self.hypr("dispatch " + window_expression(action, address))
        if result.strip() != "ok":
            raise RuntimeError(result)

    async def work_area(self, client):
        """Content box that fills the monitor's free area (minus bars, dock and decorations)."""
        monitors, border, metadata = await asyncio.gather(
            self.hypr("j/monitors"), self.hypr("j/getoption general:border_size"), self.hypr("j/stellaris:windows"))
        monitor = next((m for m in json.loads(monitors) if m["id"] == client.get("monitor")), None)
        if monitor is None:
            return None
        border = int(json.loads(border).get("int", 0))
        left, top, right, bottom = monitor["reserved"]
        dl, dt, dr, db = json.loads(metadata).get(client["address"], {}).get("reserved", [0, 0, 0, 0])
        width = round(monitor["width"] / monitor["scale"]) - left - right
        height = round(monitor["height"] / monitor["scale"]) - top - bottom
        return (monitor["x"] + left + border + dl, monitor["y"] + top + border + dt,
                width - 2 * border - dl - dr, height - 2 * border - dt - db)

    async def place(self, address, x, y, width, height):
        window_expression("focus", address)  # validates the address before interpolation
        selector = 'window="address:' + address + '"'
        await self.hypr('dispatch hl.dsp.window.fullscreen({mode="maximized",action="unset",' + selector + '})')
        await self.hypr('dispatch hl.dsp.window.float({action="on",' + selector + '})')
        await self.hypr('dispatch hl.dsp.window.resize({x=%d,y=%d,relative=false,%s})' % (width, height, selector))
        await self.hypr('dispatch hl.dsp.window.move({x=%d,y=%d,relative=false,%s})' % (x, y, selector))

    async def toggle_maximize(self, client, maximized=None):
        """KDE-style maximize for floating windows: fill the work area, restore the old geometry.

        Hyprland's own maximize is a fullscreen mode that captures every click inside it,
        so other floating windows on top could not be focused.
        """
        address = client["address"]
        entry = self.saved.setdefault(address, {})
        if client.get("fullscreen"):
            # Maximized by Hyprland itself (e.g. before this daemon ran): just leave that state.
            window_expression("focus", address)  # validates the address before interpolation
            await self.hypr('dispatch hl.dsp.window.fullscreen({mode="maximized",action="unset",window="address:%s"})' % address)
            return
        if maximized is None:
            maximized = "geometry" not in entry
        if not maximized and "geometry" in entry:
            (x, y), (width, height) = entry.pop("geometry")
            await self.place(address, x, y, width, height)
            await self.hypr(f"stellaris:maximized {address} 0")
        elif maximized and "geometry" not in entry:
            area = await self.work_area(client)
            if area is None:
                return
            entry["geometry"] = [client["at"], client["size"]]
            await self.place(address, *area)
            await self.hypr(f"stellaris:maximized {address} 1")
        self.save()

    async def handle_event(self, event, payload):
        if event == "stellarismaximize":
            # An app asked to (un)maximize itself, e.g. a GTK titlebar double-click.
            address, _, maximized = payload.partition(",")
            address = address if address.startswith("0x") else "0x" + address
            self.clients = json.loads(await self.hypr("j/clients"))
            client = next((c for c in self.clients if c["address"] == address), None)
            if client and client.get("floating"):
                await self.toggle_maximize(client, maximized == "1")
            return
        if event in ("stellarisminimize", "minimized"):
            address, _, minimized = payload.partition(",")
            if not address.startswith("0x"):
                address = "0x" + address
            # Ensure freshly mapped clients can minimize immediately.
            self.clients = json.loads(await self.hypr("j/clients"))
            await self.action({"action": "minimize" if minimized == "1" else "restore", "address": address})
        elif event == "activewindowv2" and payload:
            # Noctalia's dock/taskbar focused a hidden window: bring it back to its workspace.
            address = payload if payload.startswith("0x") else "0x" + payload
            self.clients = json.loads(await self.hypr("j/clients"))
            client = next((c for c in self.clients if c["address"] == address), None)
            if client and client.get("workspace", {}).get("name") == "special:minimized":
                await self.action({"action": "restore", "address": address})

    async def events(self):
        while True:
            writer = None
            try:
                reader, writer = await asyncio.open_unix_connection(self.socket.replace(".socket.sock", ".socket2.sock"))
                while line := await reader.readline():
                    event, _, payload = line.decode().strip().partition(">>")
                    self.wake.set()
                    await self.handle_event(event, payload)
            except (OSError, ValueError, RuntimeError, asyncio.TimeoutError) as exc:
                print(str(exc), file=sys.stderr)
            finally:
                if writer:
                    writer.close()
                    await writer.wait_closed()
            await asyncio.sleep(1)

    async def client(self, reader, writer):
        """Control socket: "watch" streams state; "request <json>" runs one action."""
        try:
            line = (await reader.readline()).decode().strip()
            command, _, payload = line.partition(" ")
            if command == "watch":
                self.watchers.add(writer)
                if self.last_state:
                    writer.write(self.last_state.encode() + b"\n")
                await reader.read()
                return
            if command != "request":
                writer.write(b"error: unknown command\n")
                return
            try:
                await self.action(json.loads(payload))
                self.error = ""
                writer.write(b"ok\n")
            except Exception as exc:
                self.error = str(exc)
                writer.write(f"error: {exc}\n".encode())
            self.wake.set()
        finally:
            self.watchers.discard(writer)
            writer.close()

    async def run(self):
        self.bus = await MessageBus().connect()
        self.bus.add_message_handler(self.receive)
        result = await self.bus.request_name(INTERFACE, NameFlag.DO_NOT_QUEUE)
        if result not in (RequestNameReply.PRIMARY_OWNER, RequestNameReply.ALREADY_OWNER):
            self.error = "Application menus unavailable: another registrar is running"
        for rule in ["type='signal',interface='org.freedesktop.DBus',member='NameOwnerChanged'",
                     "type='signal',interface='com.canonical.dbusmenu'"]:
            await self.call("org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus", "AddMatch", "s", [rule])
        if self.control.exists():
            self.control.unlink()
        server = await asyncio.start_unix_server(self.client, path=str(self.control))
        self.control.chmod(0o600)
        self.spawn(server.serve_forever())
        self.spawn(self.events())
        while True:
            try:
                await self.update()
            except (OSError, asyncio.TimeoutError, ValueError) as exc:
                print(str(exc), file=sys.stderr)
            self.wake.clear()
            try:
                await asyncio.wait_for(self.wake.wait(), 0.5)
            except asyncio.TimeoutError:
                pass


def control_socket():
    return Path(os.environ["XDG_RUNTIME_DIR"], "stellaris-desktop.sock")


async def client_main(argv):
    reader, writer = await asyncio.open_unix_connection(str(control_socket()))
    if argv[0] == "watch":
        writer.write(b"watch\n")
        await writer.drain()
        while line := await reader.readline():
            sys.stdout.write(line.decode())
            sys.stdout.flush()
        return 0
    if argv[0] == "action" and len(argv) in (2, 3):
        request = {"action": argv[1]}
        if len(argv) == 3:
            request["address"] = argv[2]
    elif argv[0] == "send" and len(argv) == 2:
        request = json.loads(argv[1])
    else:
        print(__doc__, file=sys.stderr)
        return 2
    writer.write(b"request " + json.dumps(request).encode() + b"\n")
    await writer.drain()
    reply = (await reader.readline()).decode().strip()
    writer.close()
    if reply != "ok":
        print(reply, file=sys.stderr)
        return 1
    return 0


def main(argv):
    if argv == ["serve"]:
        asyncio.run(Bridge().run())
        return 0
    if argv and argv[0] in ("watch", "action", "send"):
        try:
            return asyncio.run(client_main(argv))
        except (OSError, ValueError) as exc:
            print(f"stellaris-desktop: {exc}", file=sys.stderr)
            return 1
    print(__doc__, file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
