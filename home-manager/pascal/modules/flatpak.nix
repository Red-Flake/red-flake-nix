{ lib
, pkgs
, ...
}:
let
  flatpak = lib.getExe' pkgs.flatpak "flatpak";
in
{
  # Add the Flathub remote for user installs. Skipped when it already exists;
  # retried while the network is not up yet.
  systemd.user.services.flatpak-flathub = {
    Unit = {
      Description = "Add the Flathub remote for user Flatpak installs";
      StartLimitIntervalSec = "1h";
      StartLimitBurst = 10;
    };
    Service = {
      Type = "oneshot";
      ExecCondition = "${pkgs.writeShellScript "flathub-missing" ''
        ! ${flatpak} remote-list --user --columns=name | ${lib.getExe pkgs.gnugrep} -qx flathub
      ''}";
      ExecStart = "${flatpak} remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo";
      TimeoutStartSec = "1min";
      Restart = "on-failure";
      RestartSec = "1min";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
