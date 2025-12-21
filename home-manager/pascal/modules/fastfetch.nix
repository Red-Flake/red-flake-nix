{ config
, ...
}:
{
  # https://home-manager-options.extranix.com/?query=fastfetch&release=master
  programs.fastfetch = {
    enable = true;
    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
      logo = {
        type = "iterm";
        source = "${config.home.homeDirectory}/.red-flake/artwork/logos/RedFlake_Logo_512x512px.png";
      };
      display = {
        color = {
          title = "red";
          keys = "red";
        };
      };
      modules = [
        "title"
        "separator"
        "os"
        "host"
        "kernel"
        "uptime"
        "packages"
        "shell"
        "de"
        "wm"
        "wmtheme"
        "theme"
        "icons"
        "font"
        "terminal"
        "terminalfont"
        "cpu"
        "gpu"
        "memory"
        "swap"
        "disk"
        "break"
      ];
    };
  };
}
