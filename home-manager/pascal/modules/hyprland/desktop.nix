# stellaris-desktop: window actions (titlebars, minimize/restore) and the global-menu registrar.
{ pkgs }:
pkgs.writeShellApplication {
  name = "stellaris-desktop";
  runtimeInputs = [ (pkgs.python3.withPackages (p: [ p.dbus-next ])) ];
  text = ''exec python3 ${./bridge.py} "$@"'';
}
