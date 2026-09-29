# Stellaris: Hyprland + Noctalia

This additional desktop is enabled only for `pascal` on `stellaris`. Plasma remains
installed and the default SDDM session. The existing Intel/NVIDIA configuration is
unchanged; the compositor chooses its render device automatically.

- **Hyprland** manages windows: floating by default, macOS-style titlebars (Hyprbars),
  tiling on demand, animations, blur.
- **[Noctalia](https://docs.noctalia.dev/noctalia/) v5** is the shell: top bar, dock,
  launcher, control center (Wi-Fi, Bluetooth, audio, brightness, power), notifications,
  on-screen display, lock screen and idle handling.
- **stellaris-desktop** (`bridge.py`) is a small session daemon for what neither
  provides on Hyprland: minimize/restore and the global application menu.

## Build and start

From the flake root:

```sh
sudo nixos-rebuild switch --flake .#stellaris
```

Log out and select **Hyprland (uwsm-managed)** in SDDM. Use this entry, because UWSM
starts and stops the session services with `wayland-session@hyprland.desktop.target`.
Hyprland starts Noctalia itself (`uwsm app -- noctalia`). Select **Plasma** to return
to KDE. Save open work before switching sessions.

After a rebuild while logged in to Hyprland, run `hyprctl reload`; Home Manager does
not reload the system-wide Hyprland. Noctalia picks up its config file on its own.

If a login ever ends on a black screen, switch to a text console with
Ctrl + Alt + F3, log in and run `sudo systemctl restart display-manager` to get
the login screen back. `journalctl -b -t uwsm` shows why the session did not
start. A common cause is a graphical-session target left active by the previous
session; `default.nix` makes Home Manager's `tray.target` stop with it so that
UWSM can start after a Plasma logout.

Everything is declarative and comes from the Nix store: the Noctalia config
(`~/.config/noctalia/config.toml`, validated at build time; any Noctalia warning fails
the build), the app-menu plugin (a read-only `path` plugin source, `auto_update = "none"`),
Hyprland's config and both Hyprland plugins. Changes made in Noctalia's settings window
are stored in `~/.local/state/noctalia/settings.toml` and override the Nix config until
removed.

## Desktop behavior

- Windows open floating with square corners and a 2px border (teal when focused).
  Move them by the titlebar, resize at any edge, or Super + left/right drag.
- Qt/KDE apps, GTK apps without a header bar (LibreOffice, pavucontrol) and most
  XWayland apps get a titlebar with close, minimize and maximize on the left;
  double-click it to maximize. Apps that draw their own titlebar (libadwaita and other
  header-bar apps, Firefox, Electron with a custom frame) keep theirs.
- Maximize works like KDE: the window is resized to fill the free screen area (between
  the bar and the dock) and pressed again, returns to its previous size and position.
  Titlebar buttons, double-click, Super + F and apps' own maximize buttons all use this.
  Hyprland's built-in maximize is a fullscreen mode that captures every click inside the
  window, so other windows on top of it could not be focused; it is only used for tiled
  windows.
- **Top bar**: launcher, the focused app's name and its menus (File, Edit, …),
  workspaces in the middle, then tray, notifications, network, Bluetooth, volume,
  brightness, battery, control center and clock. Surfaces are blurred through
  Hyprland layer rules, as Noctalia's Hyprland guide recommends.
- **Dock**: pinned Dolphin, Ghostty and Firefox plus running apps, macOS-style
  magnification, running dots and window-count badges. Clicking a minimized app
  restores it to the workspace it came from.
- **Idle**: lock after five minutes, screens off after ten. Noctalia also locks before
  suspend (lid close, `systemctl suspend`) through a logind sleep inhibitor. The lock
  screen authenticates against the standard `login` PAM service.
- Weather, telemetry and theme templates (colour files written into other apps'
  configs, which are shared with Plasma) are off.

## Shortcuts

| Shortcut            | Action                                                |
| ------------------- | ----------------------------------------------------- |
| Super + Enter       | Ghostty                                               |
| Ctrl + Alt + T      | Ghostty                                               |
| Super + Space       | Launcher                                              |
| Super + S           | Control center                                        |
| Super + Comma       | Noctalia settings                                     |
| Super + E           | Dolphin                                               |
| Alt + Tab           | Window switcher                                       |
| Alt + F4            | Close window                                          |
| Super + F           | Maximize / restore (KDE-style)                        |
| Super + Shift + F   | Fullscreen / restore                                  |
| Super + T           | Toggle active window between floating and tiling      |
| Super + M           | Minimize (click its dock icon to restore)             |
| Super + Shift + M   | Show/hide the minimized workspace (recovery shortcut) |
| Super + 1–9         | Switch workspace                                      |
| Ctrl + Alt + ← / →  | Previous / next workspace                             |
| Super + Shift + 1–9 | Move window to workspace                              |
| Super + L           | Lock                                                  |
| Print               | Region screenshot (copied to the clipboard and saved) |

Volume, microphone mute and brightness keys use Noctalia (with its on-screen display);
media keys use playerctl. Keyboard layout is German, matching Plasma. Three-finger
horizontal swipes switch workspaces.

## Compatibility boundaries

Hyprland has no native minimized state and Noctalia has no minimize concept on
Hyprland. Minimizing (titlebar button, an app's own minimize button, Super + M) moves
the window to the hidden `special:minimized` workspace and remembers where it came
from. When anything focuses such a window (Noctalia's dock, taskbar or window
switcher), the daemon moves it back. An app's own minimize request reaches the daemon
through the Stellaris Hyprland plugin (`plugin/`), which forwards
`xdg_toplevel.set_minimized` and the XWayland equivalent.

Hyprland reports every new window to its app as maximized (a tiling default that stops
apps from drawing client-side decorations). The Stellaris plugin clears that for floating
windows, so apps know they are not maximized and their own maximize buttons work, and
`hyprctl stellaris:maximized <address> 0|1` keeps the app's state in sync with the
daemon's KDE-style maximize.

Titlebar detection is per window, when it opens: a Wayland window without a
server-side decoration request is tagged `stellaris-csd` and Hyprbars skips it. Qt
asks through `xdg-decoration`, GTK 3 and 4 through KDE's `server-decoration` protocol
(GTK apps with a header bar ask for client-side mode). XWayland apps that draw their
own frame (rare with `NIXOS_OZONE_WL=1`) still get a bar; add a `hyprbars:no_bar`
window rule for their class if that bothers you. `hyprland.nix` also forces the bar
on Ghostty, which runs with `gtk-titlebar = false`; add a similar rule for any app
that shows no titlebar.

An app that switches frames while running (Telegram's "Use Qt window frame") needs a
restart before its titlebar follows.

XWayland apps (Equibop and other Electron apps forced to X11, Steam, …) are scaled as
Plasma's "Apply scaling themselves" option does: Hyprland does not upscale them
(`xwayland.force_zero_scaling`), which would make them blurry at the 1.6 display scale.
Instead Hyprland loads `Xft.dpi: 153` (96 × 1.6) into XWayland at start, and apps size
their UI from it. Adjust that value in `hyprland.nix` if the display scale changes. X11
apps that ignore `Xft.dpi` appear small but sharp.

The global menu works for applications that export **Canonical DBusMenu**; Qt and
KDE apps do so in this session through qt6ct. The daemon runs a session-local
registrar, and the Stellaris plugin implements KDE's Wayland `appmenu` protocol and
reports X11 window IDs, so each window shows its own menu even when one process
has several windows. The Noctalia plugin (`noctalia-appmenu/`) renders the menus in
the bar and opens them as dropdowns with submenus, disabled/checked states and the
real actions. GTK, Electron, browsers and sandboxed apps keep their in-window menus.
`noctalia msg plugin stellaris/appmenu:menu focused open [Label]` opens a menu from a
script or keybind. (yolo-labz/noctalia-appmenu is niri-only and targets Noctalia v4,
so it is not used.)

Do not run Plasma and Hyprland concurrently as the same user: the user D-Bus and
systemd manager are shared. Sequential logout/login is supported.

## Maintenance and validation

| Path                | Role                                                                 |
| ------------------- | -------------------------------------------------------------------- |
| `default.nix`       | packages, session environment, Noctalia settings, session services   |
| `hyprland.nix`      | compositor config, keybinds, rules, Hyprland plugins, Noctalia start |
| `plugin/`           | Stellaris Hyprland plugin (minimize requests, titlebars, menus)      |
| `bridge.py`         | `stellaris-desktop` daemon (window actions, DBusMenu registrar)      |
| `desktop.nix`       | the daemon's package                                                 |
| `noctalia-appmenu/` | Noctalia v5 plugin rendering the global menu                         |

Noctalia comes from the `noctalia` flake input (with its binary cache in
`nixos/shared/caches.nix` and `flake.nix`); Hyprland 0.55 comes from nixpkgs.

Useful diagnostics inside the Hyprland session:

```sh
hyprctl configerrors
noctalia msg status
systemctl --user status stellaris-desktop.service
journalctl --user -u stellaris-desktop.service -b
stellaris-desktop watch        # live global-menu state
```

### Tests

`test_bridge.py` runs the daemon against a private D-Bus with simulated Hyprland
IPC (menu registration, exact window matching, minimize/restore bookkeeping, dock
activation, the control-socket CLI, invalid-input rejection):

```sh
nix build --impure --out-link /tmp/stellaris-test-python --expr '
  let f = builtins.getFlake ("path:" + toString ./.);
  in f.nixosConfigurations.stellaris.pkgs.python3.withPackages (p: [ p.dbus-next ])'
dbus-run-session -- /tmp/stellaris-test-python/bin/python3 -B \
  home-manager/pascal/modules/hyprland/test_bridge.py
```

`tests/integration.py` runs the real session nested inside any running Wayland
desktop (one extra window appears briefly). It starts the generated Hyprland config
with both plugins on a private runtime dir and D-Bus, then the daemon, Noctalia with
the generated config, Qt and GTK3 test apps (`tests/app.nix`) and pavucontrol. It checks that
XWayland scaling, Noctalia's bar, dock and the app-menu plugin, floating windows, titlebar
selection, the menu dropdown (without stealing focus) and its action, native and
titlebar minimize, restore through the dock path, maximize, tiling, workspaces,
monitor removal and close:

```sh
python3 home-manager/pascal/modules/hyprland/tests/integration.py
```

Not covered by these tests: GPU rendering on the DRM backend, UWSM session
start/stop from SDDM, physical monitor hotplug, lock/suspend, screen sharing and
the Wi-Fi/Bluetooth/UPower controls. Check those after the first real login.
