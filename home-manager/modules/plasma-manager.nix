{ pkgs, config, ... }:

{
  programs.plasma = {
    enable = true;

    #
    # Some high-level settings:
    #
    workspace = {
      clickItemTo = "open"; # If you liked the click-to-open default from plasma 5
      theme = "default"; # The Plasma theme. Run plasma-apply-desktoptheme --list-themes for valid options.
      colorScheme = "GradientDarkColorScheme"; # The Plasma colorscheme. Run plasma-apply-colorscheme --list-schemes for valid options.
      cursor = {
        theme = "Bibata-Modern-Classic";
        size = 24;
      };
      # lookAndFeel = "Moe-Dark"; # DO NOT SET lookAndFeel since it overrides the other theme settings! # The Plasma look and feel theme. Run plasma-apply-lookandfeel --list for valid options.
      windowDecorations.library = "org.kde.breeze"; # The library for the window decorations theme. To see available values see the library key in the org.kde.kdecoration2 section of ~/.config/kwinrc after applying the window-decoration via the settings app.
      windowDecorations.theme = "Breeze"; # The window decorations theme. To see available values see the theme key in the org.kde.kdecoration2 section of ~/.config/kwinrc after applying the window-decoration via the settings app.
      iconTheme = "Papirus-Dark"; # The Plasma icon theme.
      wallpaper = "${config.home.homeDirectory}/.local/share/wallpapers/red-flake/Red-Flake-Wallpaper_1920x1080.png"; # The Plasma wallpaper. Can be either be the path to an image file or a kpackage.
    };

    kwin = {
      virtualDesktops = {
        rows = 1;
        number = 8;
      };
    };

    hotkeys.commands."launch-konsole" = {
      name = "Launch Konsole";
      key = "Ctrl+Alt+T";
      command = "konsole";
    };

    fonts = {
      general = {
        family = "Noto Sans";
        pointSize = 11;
      };
    };

    panels = [
      # Windows-like panel at the bottom
      {
        location = "bottom";
        floating = false;
        height = 40;
        widgets = [
          # We can configure the widgets by adding the name and config
          # attributes. For example to add the the kickoff widget and set the
          # icon to "nix-snowflake-white" use the below configuration. This will
          # add the "icon" key to the "General" group for the widget in
          # ~/.config/plasma-org.kde.plasma.desktop-appletsrc.
          {
            name = "org.kde.plasma.kickoff";
            config = {
              General.icon = "${config.home.homeDirectory}/.red-flake/artwork/logos/RedFlake_Logo_32x32px.png";
            };
          }
          # Adding configuration to the widgets can also for example be used to
          # pin apps to the task-manager, which this example illustrates by
          # pinning dolphin and konsole to the task-manager by default.
          {
            name = "org.kde.plasma.icontasks";
            config = {
              General = {
                showOnlyCurrentDesktop = "false";
                showOnlyCurrentActivity = "true";
                showOnlyCurrentScreen = "true";
                launchers = [
                  "applications:org.kde.dolphin.desktop"
                  "applications:org.kde.konsole.desktop"
                  "applications:firefox.desktop"
                  "applications:org.telegram.desktop.desktop"
                  "applications:vesktop.desktop"
                  "applications:codium.desktop"
                  "applications:burpsuite.desktop"
                  "applications:bloodhound.desktop"
                  "applications:ghidra.desktop"
                  "applications:re.rizin.cutter.desktop"
                  "applications:org.wireshark.Wireshark.desktop"
                ];
              };
            };
          }
          # If no configuration is needed, specifying only the name of the
          # widget will add them with the default configuration.
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.pager"
          # If you need configuration for your widget, instead of specifying the
          # the keys and values directly using the config attribute as shown
          # above, plasma-manager also provides some higher-level interfaces for
          # configuring the widgets. See modules/widgets for supported widgets
          # and options for these widgets. The widgets below shows two examples
          # of usage, one where we add a digital clock, setting 12h time and
          {
            systemTray.items = {
              # We explicitly show bluetooth and battery
              shown = [
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.volume"
                "org.kde.plasma.battery"
                "org.kde.plasma.bluetooth"
                "org.kde.plasma.systemtray"
              ];
              # And explicitly hide networkmanagement and volume
              hidden = [
                "org.kde.plasma.brightness"
              ];
              configs.battery.showPercentage = true;
            };
          }
          {
            digitalClock = {
              calendar.firstDayOfWeek = "sunday";
              time.format = "12h";
              date.enable = false;
            };
          }
          "org.kde.plasma.showdesktop"
        ];
        hiding = "normalpanel";
      }
      # Global menu at the top
      {
        location = "top";
        height = 26;
        widgets = [
          "org.kde.plasma.appmenu"
        ];
      }
    ];


    #
    # Some mid-level settings:
    #
    shortcuts = {
      ksmserver = {
        "Lock Session" = [ "Screensaver" "Ctrl+Alt+L" ];
      };

      kwin = {
        "Expose" = "Meta+,";
        "Switch Window Down" = "Meta+J";
        "Switch Window Left" = "Meta+H";
        "Switch Window Right" = "Meta+L";
        "Switch Window Up" = "Meta+K";
        "Switch One Desktop to the Left" = "Ctrl+Alt+Left";
        "Switch One Desktop to the Right" = "Ctrl+Alt+Right";
      };
    };

    #
    # Kscreenlocker
    #
    kscreenlocker = {
      appearance.wallpaper = "${config.home.homeDirectory}/.local/share/wallpapers/red-flake/Red-Flake-Wallpaper_1920x1080.png";
    };

    #
    # Powerdevil
    #
    powerdevil = {
      battery = {
        autoSuspend = {
          action = "nothing";
          idleTimeout = null;
        };
        turnOffDisplay.idleTimeout = 900;
        dimDisplay = {
          enable = true;
          idleTimeout = 600;
        };
      };

      AC = {
        autoSuspend = {
          action = "nothing";
          idleTimeout = null;
        };
        turnOffDisplay.idleTimeout = 900;
        dimDisplay = {
          enable = true;
          idleTimeout = 600;
        };
      };
    };

    #
    # Some low-level settings:
    #
    configFile = {
      "kdeglobals"."General"."AccentColor" = "160,31,52";
      "baloofilerc"."Basic Settings"."Indexing-Enabled" = false;
      "kwinrc" = {
        "KDE"."AnimationDurationFactor" = 0.8;
        "org.kde.kdecoration2"."ButtonsOnLeft" = "SF";
        "Desktops"."Number" = {
          value = 8;
          # Forces kde to not change this value (even through the settings app).
          immutable = true;
        };
        "Effect-hidecursor" = {
          "HideOnTyping" = true;
          "InactivityDuration" = 10;
        };
        "Plugins" = {
          "dimscreenEnabled" = true;
          "hidecursorEnabled"= true;
        };
      };
      #"kscreenlockerrc" = {
      #  "Greeter"."WallpaperPlugin" = "org.kde.potd";
        # To use nested groups use / as a separator. In the below example,
        # Provider will be added to [Greeter][Wallpaper][org.kde.potd][General].
      #  "Greeter/Wallpaper/org.kde.potd/General".Provider = "bing";
      #};
    };
  };
  
}
