{ pkgs, ... }:
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
  home.packages = with pkgs.kdePackages; [ merkuro kdepim-runtime ];
}
