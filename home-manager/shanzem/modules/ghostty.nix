{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;

    enableZshIntegration = true;
    installBatSyntax = true;
    installVimSyntax = true;

    # enable systemd integration
    systemd.enable = true;

    settings = {
      font-family = "MesloLGS NF";
      font-size = 14;
      font-style = "Regular";
      font-style-bold = "Bold";
      font-style-italic = "Italic";
      font-style-bold-italic = "Bold Italic";
      font-thicken = false;
      #bold-is-bright = false;      # removed due to: compatibility handler for bold-is-bright handled error, you may be using a deprecated field: error.InvalidField

      #adjust-cell-height = "-2%";
      adjust-cursor-thickness = 15;

      cursor-style = "bar";
      cursor-style-blink = true;
      cursor-click-to-move = false;

      mouse-hide-while-typing = true;
      mouse-scroll-multiplier = 1;

      scrollback-limit = 100000000000000; # Reasonable large value (~days of output)

      # copy settings
      copy-on-select = false;

      # right click settings
      right-click-action = "context-menu";

      # background-blur = 8; # Disabled: KWin blur causes high CPU on Intel Xe
      #background-opacity = 0.98; # Increased from 0.05 for readability without blur
      fullscreen = false;

      # window settings
      initial-window = true;
      window-decoration = "auto";
      #window-padding-x = 5;
      #window-padding-y = 5;
      window-vsync = false;
      window-show-tab-bar = "always";
      window-theme = "ghostty"; # Use the background and foreground colors specified in the Ghostty configuration.

      confirm-close-surface = false;

      shell-integration = "zsh";
      shell-integration-features = [
        "sudo"
        "title"
      ];

      gtk-single-instance = true;
      gtk-titlebar = false;
      gtk-tabs-location = "bottom";
      gtk-wide-tabs = true;

      theme = "Raycast Dark";

      # app notifications
      app-notifications = "no-clipboard-copy";

      # bell
      #bell-feature = "system"; # Unknown option in current ghostty version

      # async
      async-backend = "epoll"; # Safer for Linux perf

      # auto update
      auto-update = "off";

      # recommended for the "start at login, then open windows instantly" flow
      # also set quit-after-last-window-closed = false; to keep it always running
      quit-after-last-window-closed = false;
      quit-after-last-window-closed-delay = "5m";

      # custom-shader = "shaders/aurora.glsl";
      # custom-shader = "shaders/cursor_smear.glsl";
      # custom-shader = "shaders/cursor_blaze.glsl";
      # custom-shader = "shaders/cursor_blaze_no_trail.glsl";
      # custom-shader = "shaders/cursor_frozen.glsl";
      # custom-shader = "shaders/manga_slash.glsl";
      # custom-shader = "shaders/galaxy.glsl";
      # custom-shader = "shaders/starfield.glsl";
      # custom-shader = "shaders/retro-terminal.glsl";
      # custom-shader = "shaders/gears-and-belts.glsl";
      # custom-shader = "shaders/in-game-crt.glsl";
      # custom-shader = "shaders/just-snow.glsl";
      # custom-shader = "shaders/fireworks.glsl";
      # custom-shader = "shaders/fireworks-rockets.glsl";
      # custom-shader = "shaders/sparks-from-fire.glsl";
      # custom-shader = "shaders/spotlight.glsl";
      # custom-shader = "cursor_shaders/cursor_warp.glsl";
      # custom-shader = "cursor_shaders/cursor_sweep.glsl";
      # custom-shader = "cursor_shaders/cursor_tail.glsl";
      # custom-shader = "cursor_shaders/ripple_cursor.glsl";
      # custom-shader = "cursor_shaders/sonic_boom.glsl";
      # custom-shader = "cursor_shaders/ripple_rectangle.glsl";
      # custom-shader = "cursor_shaders/ripple_rectangle_boom.glsl";
    };
  };

  # Override Ghostty's .desktop file to enable full d-bus via +new-window in order to enable faster startup and shared intances.
  xdg.desktopEntries."com.mitchellh.ghostty" = {
    name = "Ghostty";
    comment = "A terminal emulator";
    icon = "com.mitchellh.ghostty";
    exec = "${pkgs.ghostty}/bin/ghostty +new-window"; # Fast D-Bus path!
    type = "Application";
    categories = [ "System" "TerminalEmulator" ];
    startupNotify = true;
    terminal = false;
    actions = {
      "new-window" = {
        name = "New Window";
        exec = "${pkgs.ghostty}/bin/ghostty +new-window";
      };
    };
    settings = {
      Keywords = "terminal;tty;pty;";
      DBusActivatable = "true";
      StartupWMClass = "com.mitchellh.ghostty";
    };
  };
}
