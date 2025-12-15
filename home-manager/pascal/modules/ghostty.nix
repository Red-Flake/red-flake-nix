{
  config,
  lib,
  pkgs,
  ...
}:

{
  # See: https://ghostty.org/docs/config/reference
  programs.ghostty = {
    enable = true;

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
      font-thicken = true;
      bold-is-bright = false;

      #adjust-cell-height = "-2%";
      adjust-cursor-thickness = 15;

      cursor-style = "bar";
      cursor-style-blink = true;
      cursor-click-to-move = false;

      mouse-hide-while-typing = true;
      mouse-scroll-multiplier = 1;

      scrollback-limit = 4294967296;

      background-blur = 20;
      background-opacity = 0.5;
      fullscreen = false;

      # window settings
      window-decoration = "auto";
      #window-padding-x = 5;
      #window-padding-y = 5;
      window-vsync = true;
      # window-show-tab-bar = "always"; # Unknown option in current ghostty version; needs to be updated first.
      window-theme = "ghostty"; # Use the background and foreground colors specified in the Ghostty configuration.

      confirm-close-surface = false;

      shell-integration = "zsh";
      shell-integration-features = [
        "sudo"
        "title"
        #"ssh-env"  # Unknown option in current ghostty version; needs to be updated first.
        #"ssh-terminfo" # Unknown option in current ghostty version; needs to be updated first.
      ];

      gtk-single-instance = "desktop";
      gtk-titlebar = false;
      gtk-tabs-location = "top";
      gtk-wide-tabs = true;

      theme = "tokyonight_night";

      # app notifications
      app-notifications = "no-clipboard-copy";

      # bell
      # bell-feature = "system"; # Unknown option in current ghostty version; needs to be updated first.

      # async
      # async-backend = "auto"; # Unknown option in current ghostty version; needs to be updated first.

      # auto update
      auto-update = "off";

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
}
