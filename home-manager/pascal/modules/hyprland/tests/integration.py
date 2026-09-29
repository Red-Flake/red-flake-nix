"""End-to-end check of the Stellaris Hyprland session, nested inside a running Wayland session.

Starts the generated Hyprland config (with both plugins) using the Wayland backend in a
private runtime dir and D-Bus session, then the stellaris-desktop daemon, Noctalia with the
generated config and app-menu plugin, a Qt test app and a GTK4 app. Exercises floating
windows, titlebars, the global menu, minimize/restore through the dock path, tiling,
workspaces, monitor removal and close. Nothing touches the host compositor apart from one
nested window.

Run from the flake root inside a Wayland session:  python3 home-manager/pascal/modules/hyprland/tests/integration.py
"""
import json
import os
import pathlib
import shutil
import signal
import subprocess
import sys
import socket as socket_module
import tempfile
import threading
import time

HERE = pathlib.Path(__file__).resolve().parent
FLAKE = HERE.parents[4]
EXPRESSION = '''
let
  f = builtins.getFlake ("path:" + toString %s);
  host = f.nixosConfigurations.stellaris;
  pkgs = host.pkgs;
  home = host.config.home-manager.users.pascal;
in {
  hyprlandConfig = home.xdg.configFile."hypr/hyprland.lua".source;
  noctaliaConfig = home.xdg.configFile."noctalia/config.toml".source;
  qt6ct = home.xdg.configFile."qt6ct/qt6ct.conf".source;
  testApp = import %s { inherit pkgs; };
  desktop = import %s { inherit pkgs; };
  hyprland = host.config.programs.hyprland.package;
  noctalia = home.programs.noctalia.package;
  inherit (pkgs) pavucontrol grim dbus xrdb;
}
''' % (FLAKE, HERE / 'app.nix', HERE.parent / 'desktop.nix')

if 'STELLARIS_TEST_BUS' not in os.environ:
    # Re-run inside a private session bus so no host services are touched.
    subprocess.run(['nix', 'build', '--impure', '--no-link', '--expr', f'builtins.attrValues ({EXPRESSION})'], check=True)
    built = json.loads(subprocess.run(['nix', 'eval', '--impure', '--json', '--expr', f'builtins.mapAttrs (_: toString) ({EXPRESSION})'],
                                      check=True, capture_output=True, text=True).stdout)
    work = pathlib.Path(tempfile.mkdtemp(prefix='sit', dir='/tmp'))
    bus = work / 'bus.conf'
    bus.write_text('<!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-Bus Bus Configuration 1.0//EN" '
                   '"http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd"><busconfig><type>session</type>'
                   '<listen>unix:tmpdir=/tmp</listen><policy context="default">'
                   '<allow send_destination="*" eavesdrop="true"/><allow eavesdrop="true"/><allow own="*"/></policy></busconfig>')
    env = os.environ | {'STELLARIS_TEST_BUS': str(work), 'STELLARIS_TEST_PATHS': json.dumps(built)}
    try:
        sys.exit(subprocess.run([built['dbus'] + '/bin/dbus-run-session', '--config-file=' + str(bus), '--',
                                 sys.executable, __file__], env=env).returncode)
    finally:
        shutil.rmtree(work, ignore_errors=True)

paths = json.loads(os.environ['STELLARIS_TEST_PATHS'])
work = pathlib.Path(os.environ['STELLARIS_TEST_BUS'])
runtime = work / 'run'
runtime.mkdir(mode=0o700)
config = work / 'config'
for app in ('noctalia', 'qt6ct'):
    (config / app).mkdir(parents=True)
(config / 'noctalia/config.toml').symlink_to(paths['noctaliaConfig'])
(config / 'qt6ct/qt6ct.conf').symlink_to(paths['qt6ct'])
env = os.environ.copy()
env.update(XDG_RUNTIME_DIR=str(runtime), XDG_CONFIG_HOME=str(config), XDG_CACHE_HOME=str(work / 'cache'),
           XDG_STATE_HOME=str(work / 'state'), XDG_DATA_HOME=str(work / 'data'),
           HYPRLAND_NO_SD_VARS='1', HYPRLAND_NO_SD_NOTIFY='1', XDG_CURRENT_DESKTOP='Hyprland',
           WAYLAND_DISPLAY=os.path.join(os.environ['XDG_RUNTIME_DIR'], os.environ.get('WAYLAND_DISPLAY', 'wayland-0')),
           # No DRM devices: Hyprland falls back to its nested Wayland backend.
           AQ_DRM_DEVICES='/dev/dri/nonexistent',
           QT_QPA_PLATFORM='wayland', QT_QPA_PLATFORMTHEME='qt6ct', QT_WAYLAND_DISABLE_WINDOWDECORATION='1',
           DBUS_SYSTEM_BUS_ADDRESS='unix:path=/nonexistent',
           PATH=paths['noctalia'] + '/bin:' + paths['desktop'] + '/bin:' + os.environ['PATH'])
for key in ('NOTIFY_SOCKET', 'HYPRLAND_INSTANCE_SIGNATURE'):
    env.pop(key, None)
logs = pathlib.Path(os.environ.get('STELLARIS_TEST_LOGS', work / 'logs'))
logs.mkdir(parents=True, exist_ok=True)
children, results = [], []


def start(cmd, name, stdin=None):
    log = open(logs / f'{name}.log', 'w')
    # Own process group: teardown also reaches processes they fork (Hyprland forks itself).
    process = subprocess.Popen(cmd, env=env, stdout=log, stderr=log, stdin=stdin, text=True, start_new_session=True)
    children.append(process)
    return process


def run(*cmd):
    result = subprocess.run(cmd, env=env, capture_output=True, text=True, timeout=10)
    if result.returncode != 0:
        print('command failed:', ' '.join(cmd[:4]), (result.stdout + result.stderr).strip()[:500], flush=True)
        return None
    return result.stdout.strip()


def ctl(*args):
    return run(paths['hyprland'] + '/bin/hyprctl', *args) or ''


def desktop(*args):
    if run('stellaris-desktop', *args) is None:
        raise RuntimeError('stellaris-desktop ' + ' '.join(args))


def state():
    """First line of the daemon's state stream."""
    process = subprocess.Popen(['stellaris-desktop', 'watch'], env=env, stdout=subprocess.PIPE, text=True)
    try:
        return json.loads(process.stdout.readline())
    finally:
        process.kill()
        process.wait()


def until(check, description, tries=100):
    for _ in range(tries):
        try:
            if value := check():
                return value
        except (ValueError, KeyError, RuntimeError, StopIteration, TypeError):
            pass
        time.sleep(.1)
    raise AssertionError(description)


def ok(name):
    results.append(name)
    print('PASS', name, flush=True)


def clients():
    return json.loads(ctl('-j', 'clients'))


def window(address):
    return next(w for w in clients() if w['address'] == address)


def layers():
    return ctl('layers')


def screenshot(name):
    subprocess.run([paths['grim'] + '/bin/grim', '-o', 'TEST-1', str(logs / name)], env=env)


try:
    def x_sockets():
        return {p for p in pathlib.Path('/tmp/.X11-unix').glob('X*') if p.name[1:].isdigit()}
    x_displays = x_sockets()
    start([paths['hyprland'] + '/bin/Hyprland', '-c', paths['hyprlandConfig']], 'hyprland')
    socket = until(lambda: next(runtime.glob('hypr/*/.socket.sock'), None), 'compositor socket')
    env['HYPRLAND_INSTANCE_SIGNATURE'] = socket.parent.name
    env['WAYLAND_DISPLAY'] = until(lambda: next((p.name for p in runtime.glob('wayland-*') if not p.name.endswith('.lock')), None), 'display')

    def record_events():
        # Hyprland's event stream, for diagnosing failures.
        with socket_module.socket(socket_module.AF_UNIX) as events, open(logs / 'events.log', 'w') as out:
            events.connect(str(socket.parent / '.socket2.sock'))
            for line in events.makefile():
                out.write(line)
                out.flush()
    threading.Thread(target=record_events, daemon=True).start()
    time.sleep(1)
    errors, plugins = ctl('configerrors'), ctl('plugin', 'list')
    assert not errors, errors
    assert 'stellaris-desktop' in plugins and 'hyprbars' in plugins, plugins
    ok('Hyprland config loads without errors; stellaris-desktop and hyprbars loaded')
    x_display = until(lambda: next(iter(x_sockets() - x_displays), None), 'XWayland display')
    resources = until(lambda: subprocess.run([paths['xrdb'] + '/bin/xrdb', '-query'], env=env | {'DISPLAY': ':' + x_display.name[1:]},
                                             capture_output=True, text=True).stdout, 'X resources')
    assert 'Xft.dpi:\t153' in resources and 'true' in ctl('getoption', 'xwayland:force_zero_scaling'), resources
    ok('XWayland apps render unscaled and get Xft.dpi from the start hook')
    ctl('output', 'create', 'headless', 'TEST-1')
    ctl('keyword', 'monitor', 'TEST-1,1280x800@60,auto,1')
    ctl('dispatch', 'hl.dsp.focus({ monitor = "TEST-1" })')

    daemon = start(['stellaris-desktop', 'serve'], 'stellaris-desktop')
    until(state, 'stellaris-desktop state stream')
    shell = start(['noctalia'], 'noctalia')
    until(lambda: 'noctalia-bar' in layers() and 'noctalia-dock' in layers(), 'Noctalia bar and dock layers', 300)
    listed = until(lambda: run('noctalia', 'msg', 'plugins', 'list'), 'plugin list')
    assert 'stellaris/appmenu' in listed, listed
    ok('Noctalia shows its bar and dock; stellaris/appmenu plugin is loaded')

    app = start([paths['testApp'] + '/bin/stellaris-test-windows'], 'app', subprocess.PIPE)
    qt = until(lambda: w if len(w := [c for c in clients() if c['class'] == 'stellaris-test-windows']) >= 2 else None, 'two Qt windows')
    first = next(w for w in qt if w['title'] == 'Stellaris test 1')
    second = next(w for w in qt if w['title'] == 'Stellaris test 2')
    address = first['address']
    assert all(w['floating'] for w in qt)
    assert not any(t.startswith('stellaris-csd') for w in qt for t in w['tags']), qt
    ok('windows open floating; Qt windows keep their hyprbar')

    # GTK asks for a server-side frame through KDE's server-decoration protocol.
    for command, title in (([paths['pavucontrol'] + '/bin/pavucontrol'], 'Volume Control'),
                           ([paths['testApp'] + '/bin/stellaris-test-gtk3'], 'Stellaris GTK3 test')):
        gtk_process = start(command, title)
        gtk = until(lambda: next(w for w in clients() if w['title'] == title), title, 200)
        assert not any(t.startswith('stellaris-csd') for t in gtk['tags']), gtk
        gtk_process.terminate()
    ok('GTK4 and GTK3 windows without a header bar (pavucontrol, LibreOffice) get a hyprbar')

    gtk_process = start([paths['testApp'] + '/bin/stellaris-test-gtk3', '--headerbar'], 'gtk3-headerbar')
    gtk = until(lambda: next(w for w in clients() if w['title'] == 'Stellaris GTK3 headerbar test'), 'GTK3 header bar window', 200)
    assert any(t.startswith('stellaris-csd') for t in gtk['tags']), gtk
    gtk_process.terminate()
    ok('client-side decorated (GTK header bar) window gets no second titlebar')

    desktop('action', 'activate', address)
    menu = until(lambda: s if (s := state())['active']['address'] == address and s['menus'] else None, 'global menu state')
    assert menu['menus'][0]['text'] == 'Window1', menu
    assert menu['app'], menu
    time.sleep(1)
    screenshot('bar.png')
    print('ipc:', run('noctalia', 'msg', 'plugin', 'stellaris/appmenu:menu', 'focused', 'open', 'Window1'), flush=True)
    until(lambda: 'noctalia-attached-panel' in layers() or 'noctalia-panel' in layers(), 'app-menu dropdown opens', 50)
    time.sleep(.5)
    assert json.loads(ctl('-j', 'activewindow'))['address'] == address, 'dropdown stole window focus'
    assert state()['menuKey'] == menu['menuKey']
    screenshot('menu-open.png')
    item = menu['menus'][0]['children'][0]
    desktop('send', json.dumps({'action': 'menu-click', 'id': item['id'], 'key': menu['menuKey']}))
    until(lambda: 'clicked 1' in (logs / 'app.log').read_text(), 'menu action reached the app')
    run('noctalia', 'msg', 'panel-close')
    ok('global menu: bar dropdown opens without stealing focus; its action reaches the app')
    desktop('action', 'activate', second['address'])
    until(lambda: state()['menus'][0]['text'] == 'Window2', 'menu follows focus')
    ok('global menu follows focus between windows of one process')

    app.stdin.write('minimize\n')
    app.stdin.flush()
    until(lambda: window(address)['workspace']['name'] == 'special:minimized', 'native minimize')
    ok('application minimize request hides the window')
    # Noctalia's dock activates a window through the toplevel protocol; Hyprland then focuses it.
    ctl('dispatch', 'hl.dsp.focus({ window = "address:%s" })' % address)
    until(lambda: window(address)['workspace']['id'] == first['workspace']['id'], 'dock activation restores')
    ok('activating a minimized window (dock) restores it to its workspace')

    desktop('action', 'activate', address)
    time.sleep(.3)
    before = window(address)
    desktop('action', 'maximize')
    until(lambda: window(address)['size'][0] > before['size'][0] + 100, 'titlebar maximize')
    grown = window(address)
    # KDE-style: no Hyprland fullscreen state, so other windows stay clickable.
    assert grown['fullscreen'] == 0, grown
    assert not json.loads(ctl('-j', 'activeworkspace'))['hasfullscreen']
    desktop('action', 'maximize')
    until(lambda: window(address)['size'] == before['size'] and window(address)['at'] == before['at'], 'titlebar restore')
    # The first window was minimized by the app earlier and Wayland has no un-minimize
    # event, so Qt still considers it minimized; use the second window for the app request.
    other = window(second['address'])
    app.stdin.write('maximize\n')
    app.stdin.flush()
    until(lambda: window(other['address'])['size'][0] > other['size'][0] + 100, 'app maximize request')
    assert window(other['address'])['fullscreen'] == 0
    desktop('action', 'maximize', other['address'])
    until(lambda: window(other['address'])['size'] == other['size'], 'restore after app maximize')
    desktop('action', 'minimize')
    until(lambda: window(address)['workspace']['name'] == 'special:minimized', 'titlebar minimize')
    desktop('action', 'activate', address)
    until(lambda: window(address)['workspace']['name'] != 'special:minimized', 'restore')
    ok('KDE-style maximize (titlebar and app request) keeps other windows clickable; restore; minimize')

    desktop('action', 'tile', address)
    until(lambda: not window(address)['floating'], 'tiling on demand')
    desktop('action', 'tile', address)
    until(lambda: window(address)['floating'], 'back to floating')
    desktop('action', 'workspace-3', address)
    until(lambda: window(address)['workspace']['id'] == 3, 'move to workspace')
    ok('tiling toggle and move to workspace')

    ctl('dispatch', 'hl.dsp.focus({ monitor = "TEST-1" })')
    desktop('action', 'activate', second['address'])
    monitor = next(m for m in json.loads(ctl('-j', 'monitors')) if m['name'] == 'TEST-1')
    width, height = monitor['width'] / monitor['scale'], monitor['height'] / monitor['scale']
    # Hover the dock so the screenshot shows its magnification.
    ctl('dispatch', 'hl.dsp.cursor.move({ x = %d, y = %d })' % (monitor['x'] + width / 2, monitor['y'] + height - 40))
    time.sleep(1.5)
    screenshot('desktop.png')
    ctl('output', 'remove', 'TEST-1')
    time.sleep(1)
    assert shell.poll() is None and daemon.poll() is None
    ok('monitor removal keeps Noctalia and the daemon running')

    desktop('action', 'close', address)
    until(lambda: all(w['address'] != address for w in clients()), 'close')
    ok('close')
    print(f'ALL {len(results)} CHECKS PASSED (logs: {logs})')
finally:
    for process in reversed(children):
        for sig in (signal.SIGTERM, signal.SIGKILL):
            try:
                os.killpg(process.pid, sig)
            except ProcessLookupError:
                break
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                pass
            time.sleep(0.5)
