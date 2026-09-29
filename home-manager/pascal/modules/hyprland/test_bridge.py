"""Run with the module's Python environment under dbus-run-session.

Tests exercise actual D-Bus registration/menu calls and simulated compositor IPC;
they do not connect to the user's desktop bus or control real windows.
"""
import asyncio
import json
import os
import unittest
import tempfile
from pathlib import Path
from unittest.mock import AsyncMock, patch

from dbus_next import Message, MessageType, Variant
from dbus_next.aio import MessageBus
from dbus_next.service import ServiceInterface, method
import bridge as bridge_module
from bridge import Bridge, INTERFACE, PATH, MENU, menu_tree, window_expression


class Menu(ServiceInterface):
    def __init__(self):
        super().__init__(MENU)
        self.clicked = []

    @method()
    def GetLayout(self, parent: 'i', depth: 'i', properties: 'as') -> 'u(ia{sv}av)':
        return [1, [0, {}, [Variant('(ia{sv}av)', [1, {'label': Variant('s', '_File')}, [
            Variant('(ia{sv}av)', [2, {'label': Variant('s', '_Open')}, []])]])]]]

    @method()
    def AboutToShow(self, item: 'i') -> 'b':
        return False

    @method()
    def Event(self, item: 'i', event: 's', data: 'v', timestamp: 'u'):
        self.clicked.append((item, event))


class ProtocolTests(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        data = Path(self.temporary.name, 'data')
        (data / 'applications').mkdir(parents=True)
        (data / 'applications' / 'org.example.TestApp.desktop').write_text(
            '[Desktop Entry]\nType=Application\nName=Test App\nStartupWMClass=test-app\n')
        self.env = patch.dict(os.environ, {'XDG_RUNTIME_DIR': self.temporary.name, 'HYPRLAND_INSTANCE_SIGNATURE': 'test',
                                           'XDG_DATA_HOME': str(data), 'XDG_DATA_DIRS': str(data)})
        self.env.start()
        self.bridge = Bridge()
        self.bridge.restore_file = Path(self.temporary.name) / "restore.json"
        self.bridge.bus = await MessageBus().connect()
        self.bridge.bus.add_message_handler(self.bridge.receive)
        await self.bridge.bus.request_name(INTERFACE)
        self.client = await MessageBus().connect()
        self.menu = Menu()
        self.client.export('/Menu', self.menu)
        self.window = {'address': '0xabc', 'pid': os.getpid(), 'class': 'test-app', 'monitor': 0,
                       'workspace': {'id': 2, 'name': '2'}, 'title': 'Test', 'floating': True,
                       'fullscreen': 0, 'at': [300, 200], 'size': [800, 600]}
        self.replies = {'j/clients': json.dumps([self.window]),
                        'j/activewindow': json.dumps(self.window), 'j/activeworkspace': '{"id": 2}',
                        # 2560x1600 at scale 1.6, Noctalia bar (34) and dock (80) reserved.
                        'j/monitors': json.dumps([{'id': 0, 'x': 0, 'y': 0, 'width': 2560, 'height': 1600,
                                                   'scale': 1.6, 'reserved': [0, 34, 0, 80]}]),
                        'j/getoption general:border_size': '{"int": 2}',
                        'j/stellaris:windows': '{"0xabc": {"reserved": [0, 30, 0, 0]}}'}
        self.bridge.hypr = AsyncMock(side_effect=lambda command: self.replies.get(command, 'ok'))

    async def asyncTearDown(self):
        self.client.disconnect()
        self.bridge.bus.disconnect()
        await self.client.wait_for_disconnect()
        await self.bridge.bus.wait_for_disconnect()
        self.env.stop()
        self.temporary.cleanup()

    async def register(self, wid=17, path='/Menu', client=None):
        result = await (client or self.client).call(Message(destination=INTERFACE, path=PATH,
            interface=INTERFACE, member='RegisterWindow', signature='uo', body=[wid, path]))
        self.assertEqual(result.message_type, MessageType.METHOD_RETURN)

    async def update(self):
        await self.bridge.update()

    async def test_registration_layout_click_and_focus_change(self):
        await self.register()
        await self.update()
        self.assertEqual(self.bridge.tree[0]['text'], 'File')
        self.assertEqual(self.bridge.tree[0]['children'][0]['text'], 'Open')
        await self.bridge.action({'action': 'menu-click', 'id': 2, 'key': self.bridge.menu_key})
        self.assertEqual(self.menu.clicked, [(2, 'clicked')])
        old_key = self.bridge.menu_key
        self.replies['j/activewindow'] = '{}'
        await self.update()
        self.assertEqual(self.bridge.tree, [])
        await self.bridge.action({'action': 'menu-click', 'id': 2, 'key': old_key})
        self.assertEqual(len(self.menu.clicked), 1)

    async def test_ambiguous_menu_is_not_shown(self):
        await self.register()
        await self.register(18, '/AnotherMenu')
        await self.update()
        self.assertIsNone(self.bridge.menu_key)
        self.assertEqual(self.bridge.tree, [])

    async def test_other_client_cannot_unregister(self):
        await self.register()
        other = await MessageBus().connect()
        try:
            await other.call(Message(destination=INTERFACE, path=PATH, interface=INTERFACE,
                member='UnregisterWindow', signature='u', body=[17]))
            self.assertIn((self.client.unique_name, 17), self.bridge.registrations)
        finally:
            other.disconnect()
            await other.wait_for_disconnect()

    async def test_wayland_clients_can_reuse_a_window_id(self):
        await self.register()
        other = await MessageBus().connect()
        try:
            await self.register(client=other)
            self.assertEqual(len(self.bridge.registrations), 2)
            result = await self.client.call(Message(destination=INTERFACE, path=PATH,
                interface=INTERFACE, member='GetMenus'))
            self.assertEqual(len(result.body[0]), 2)
        finally:
            other.disconnect()
            await other.wait_for_disconnect()

    async def test_minimize_and_restore_original_workspace(self):
        await self.update()
        await self.bridge.action({'action': 'minimize', 'address': '0xabc'})
        self.assertIn('workspace="special:minimized",follow=false', self.bridge.hypr.call_args.args[0])
        self.bridge.clients[0]['workspace']['name'] = 'special:minimized'
        self.bridge.workspace = 4
        self.bridge.hypr.reset_mock()
        await self.bridge.action({'action': 'activate', 'address': '0xabc'})
        calls = [c.args[0] for c in self.bridge.hypr.call_args_list]
        self.assertIn('workspace=2,follow=false', calls[0])
        self.assertIn('hl.dsp.focus', calls[1])

    async def test_exact_x11_menu_disambiguates_same_process(self):
        await self.register()
        await self.register(18, '/AnotherMenu')
        self.replies['j/stellaris:windows'] = '{"0xabc":{"xid":17}}'
        await self.update()
        self.assertEqual(self.bridge.menu_key, (self.client.unique_name, '/Menu'))

    async def test_exact_wayland_menu_disambiguates_same_process(self):
        await self.register()
        await self.register(18, '/AnotherMenu')
        self.replies['j/stellaris:windows'] = json.dumps({'0xabc': {'menu': [self.client.unique_name, '/Menu']}})
        await self.update()
        self.assertEqual(self.bridge.menu_key, (self.client.unique_name, '/Menu'))

    async def test_active_action_queries_current_focus(self):
        await self.update()
        self.bridge.active = {'address': '0xdead'}
        await self.bridge.action({'action': 'maximize'})
        self.assertTrue(any('address:0xabc' in c for c in self.dispatched()))

    async def test_state_names_the_app_from_its_desktop_entry(self):
        await self.update()
        state = json.loads(self.bridge.last_state)
        self.assertEqual(state['app'], 'Test App')
        self.assertEqual(state['active'], {'address': '0xabc', 'class': 'test-app', 'title': 'Test'})

    async def test_dock_activation_restores_minimized_window(self):
        await self.update()
        await self.bridge.action({'action': 'minimize', 'address': '0xabc'})
        self.window['workspace'] = {'id': -98, 'name': 'special:minimized'}
        self.replies['j/clients'] = json.dumps([self.window])
        self.bridge.hypr.reset_mock()
        await self.bridge.handle_event('activewindowv2', 'abc')
        calls = [c.args[0] for c in self.bridge.hypr.call_args_list]
        self.assertIn('dispatch hl.dsp.window.move({workspace=2,follow=false,window="address:0xabc"})', calls)
        self.assertIn('hl.dsp.focus', calls[-1])
        self.bridge.hypr.reset_mock()
        self.window['workspace'] = {'id': 2, 'name': '2'}
        self.replies['j/clients'] = json.dumps([self.window])
        await self.bridge.handle_event('activewindowv2', 'abc')
        self.assertEqual([c.args[0] for c in self.bridge.hypr.call_args_list], ['j/clients'])

    async def test_cli_round_trip_over_control_socket(self):
        await self.update()
        server = await asyncio.start_unix_server(self.bridge.client, path=str(self.bridge.control))
        try:
            self.bridge.hypr.reset_mock()
            self.assertEqual(await bridge_module.client_main(['action', 'maximize']), 0)
            self.assertIn('dispatch hl.dsp.window.move({x=2,y=66,relative=false,window="address:0xabc"})',
                          self.dispatched())
            self.assertEqual(await bridge_module.client_main(['send', '{"action": "goto-workspace", "workspace": 0}']), 1)
        finally:
            server.close()
            await server.wait_closed()

    async def test_workspace_switching(self):
        await self.bridge.action({'action': 'goto-workspace', 'workspace': 4, 'monitor': 'eDP-1'})
        calls = [c.args[0] for c in self.bridge.hypr.call_args_list]
        self.assertEqual(calls, ['dispatch hl.dsp.focus({monitor="eDP-1"})',
                                 'dispatch hl.dsp.focus({workspace=4})'])
        self.bridge.hypr.reset_mock()
        await self.bridge.action({'action': 'next-workspace'})
        self.assertEqual(self.bridge.hypr.call_args.args[0], 'dispatch hl.dsp.focus({workspace="r+1"})')

    async def test_workspace_inputs_cannot_inject_lua(self):
        for request in [{'action': 'goto-workspace', 'workspace': '1})os.exit(({'},
                        {'action': 'goto-workspace', 'workspace': 0},
                        {'action': 'next-workspace', 'monitor': 'eDP-1"}) os.exit() --'}]:
            with self.assertRaises(ValueError):
                await self.bridge.action(request)
        self.bridge.hypr.assert_not_called()

    def dispatched(self):
        return [c.args[0] for c in self.bridge.hypr.call_args_list if c.args[0].startswith('dispatch')]

    async def test_maximize_fills_free_area_and_restores(self):
        await self.update()
        self.bridge.hypr.reset_mock()
        await self.bridge.action({'action': 'maximize', 'address': '0xabc'})
        calls = self.dispatched()
        # Width 1600 - 2*2 border; height 1000 - 34 bar - 80 dock - 2*2 border - 30 titlebar.
        self.assertIn('dispatch hl.dsp.window.resize({x=1596,y=852,relative=false,window="address:0xabc"})', calls)
        self.assertIn('dispatch hl.dsp.window.move({x=2,y=66,relative=false,window="address:0xabc"})', calls)
        self.assertFalse(any('mode="maximized",window' in c for c in calls), 'no Hyprland fullscreen maximize')
        self.assertIn('stellaris:maximized 0xabc 1', [c.args[0] for c in self.bridge.hypr.call_args_list])
        self.bridge.hypr.reset_mock()
        await self.bridge.action({'action': 'maximize', 'address': '0xabc'})
        calls = self.dispatched()
        self.assertIn('dispatch hl.dsp.window.resize({x=800,y=600,relative=false,window="address:0xabc"})', calls)
        self.assertIn('dispatch hl.dsp.window.move({x=300,y=200,relative=false,window="address:0xabc"})', calls)
        self.assertIn('stellaris:maximized 0xabc 0', [c.args[0] for c in self.bridge.hypr.call_args_list])

    async def test_app_maximize_request_maximizes_kde_style(self):
        await self.update()
        self.bridge.hypr.reset_mock()
        await self.bridge.handle_event('stellarismaximize', 'abc,1')
        self.assertIn('dispatch hl.dsp.window.move({x=2,y=66,relative=false,window="address:0xabc"})', self.dispatched())
        self.bridge.hypr.reset_mock()
        await self.bridge.handle_event('stellarismaximize', 'abc,1')
        self.assertEqual(self.dispatched(), [], 'already maximized')
        await self.bridge.handle_event('stellarismaximize', 'abc,0')
        self.assertIn('dispatch hl.dsp.window.move({x=300,y=200,relative=false,window="address:0xabc"})', self.dispatched())

    async def test_hyprland_maximized_window_is_just_unmaximized(self):
        self.window['fullscreen'] = 1
        self.replies['j/clients'] = json.dumps([self.window])
        await self.update()
        self.bridge.hypr.reset_mock()
        await self.bridge.action({'action': 'maximize', 'address': '0xabc'})
        self.assertEqual(self.dispatched(), [
            'dispatch hl.dsp.window.fullscreen({mode="maximized",action="unset",window="address:0xabc"})'])

    async def test_closed_windows_are_not_dispatched(self):
        await self.update()
        self.bridge.hypr.reset_mock()
        await self.bridge.action({'action': 'close', 'address': '0xdead'})
        self.bridge.hypr.assert_not_called()

    async def test_unchanged_state_is_not_republished(self):
        sent = []

        class Watcher:
            def write(self, data):
                sent.append(data)
        self.bridge.watchers.add(Watcher())
        await self.update()
        await self.update()
        self.assertEqual(len(sent), 1)


class DataTests(unittest.TestCase):
    def test_addresses_cannot_inject_lua(self):
        for address in ['', '0xabc\"); os.execute("bad")', 'address:0xabc', '../bad']:
            with self.assertRaises(ValueError):
                window_expression('close', address)

    def test_menu_state_and_hidden_entries(self):
        layout = [0, {}, [Variant('(ia{sv}av)', [1, {
            'label': Variant('s', '_Disabled'), 'enabled': Variant('b', False),
            'toggle-state': Variant('i', 1), 'children-display': Variant('s', 'submenu')}, []]), Variant('(ia{sv}av)', [2, {
            'visible': Variant('b', False)}, []])]]
        entries = menu_tree(layout)['children']
        self.assertEqual(len(entries), 1)
        self.assertFalse(entries[0]['enabled'])
        self.assertTrue(entries[0]['checked'])
        self.assertTrue(entries[0]['submenu'])


if __name__ == '__main__':
    unittest.main()
