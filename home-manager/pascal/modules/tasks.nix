{ inputs, pkgs, ... }:
let
  # beacon's t CLI, from the beacon flake input
  beaconT = inputs.beacon.packages.${pkgs.stdenv.hostPlatform.system}.t;
in
{
  accounts.calendar = {
    basePath = ".local/share/calendars";
    accounts.radicale = {
      primary = true;
      remote = {
        type = "caldav";
        url = "https://dav.netcat.rocks/";
        userName = "ppeinecke@netcat.rocks";
        # Decrypted by sops-nix from secrets/stellaris.yaml (see SECRETS.md)
        passwordCommand = [ "${pkgs.coreutils}/bin/cat" "/run/secrets/radicale" ];
      };
      local = {
        type = "filesystem";
        fileExt = ".ics";
      };
      vdirsyncer = {
        enable = true;
        collections = [ "from a" "from b" ];
        metadata = [ "color" "displayname" ];
        itemTypes = [ "VTODO" ];
      };
    };
  };

  programs.vdirsyncer.enable = true;
  services.vdirsyncer = {
    enable = true;
    frequency = "*:0/5";
  };

  programs.todoman = {
    enable = true;
    glob = "radicale/*";
    extraConfig = ''
      date_format = "%Y-%m-%d"
      time_format = "%H:%M"
      default_list = "Todo"
      humanize = True
    '';
  };

  # Merkuro: DAV account is added once by hand (Akonadi resources can't be configured declaratively)
  # kdepim-addons: "PIM Events" plugin that shows Akonadi events/tasks in the Digital Clock calendar
  # kcontacts: org.kde.contacts QML module for Merkuro's system tray applet (runs inside plasmashell)
  # akonadi-calendar: KCalendarCore serializer so plasmashell can decode Akonadi events (Merkuro has it via its wrapper)
  # akonadi-contacts: same for contacts, used by Merkuro's contacts tray applet
  home.packages = (with pkgs.kdePackages; [ merkuro kdepim-runtime kdepim-addons kcontacts akonadi-calendar akonadi-contacts ]) ++ [ beaconT ];

  # Config for beacon
  home.sessionVariables = {
    BEACON_CALDAV_URL = "https://dav.netcat.rocks/";
    BEACON_CALDAV_USER = "ppeinecke@netcat.rocks";
    BEACON_CALDAV_PASSWORD_CMD = "cat /run/secrets/radicale";
    BEACON_SERVER_URL = "https://beacon.netcat.rocks";
    BEACON_TOKEN_FILE = "/run/secrets/beacon-token";
  };
}
