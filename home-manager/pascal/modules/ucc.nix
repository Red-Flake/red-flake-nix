{ lib
, pkgs
, inputs ? null
, ...
}:

let
  # `pkgs.ucc` is the HPC UCC library (no tray binary). Prefer the flake input.
  uccPkg =
    if inputs != null && inputs ? ucc then
      inputs.ucc.packages.${pkgs.system}.ucc
    else
      pkgs.ucc;

  uccTray = lib.getExe' uccPkg "ucc-tray";
in
{
  # Enable UCC (Uniwill Control Center) tray autostart
  xdg.configFile."autostart/ucc-tray.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=UCC Tray
    Exec=${uccTray}
    Terminal=false
    X-GNOME-Autostart-enabled=true
  '';
}
