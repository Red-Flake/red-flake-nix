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
        # Don't use the built-in `de` module here: with version detection enabled,
        # fastfetch may spawn `plasmashell --version`, which can abort (SIGABRT)
        # and create a coredump in restricted terminal contexts where Qt can't
        # connect to Wayland/X11. Show the DE from environment instead.
        {
          type = "command";
          key = "DE";
          text = "printf '%s' \"\${XDG_CURRENT_DESKTOP:-\${XDG_SESSION_DESKTOP:-unknown}}\"";
          format = "{}";
        }
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
