{ pkgs, ... }:

{
  programs.plasma = {
    enable = true;

    #
    # Some high-level settings:
    #
    workspace = {
      clickItemTo = "open"; # If you liked the click-to-open default from plasma 5
      lookAndFeel = "org.kde.breezedark.desktop";
      cursor = {
        theme = "Breeze";
        size = 24;
      };
      iconTheme = "Flat-Remix-Blue-Dark";
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Patak/contents/images/1080x1920.png";
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
        height = 36;
        widgets = [
          # We can configure the widgets by adding the name and config
          # attributes. For example to add the the kickoff widget and set the
          # icon to "nix-snowflake-white" use the below configuration. This will
          # add the "icon" key to the "General" group for the widget in
          # ~/.config/plasma-org.kde.plasma.desktop-appletsrc.
          {
            name = "org.kde.plasma.kickoff";
            config = {
              General.icon = "nix-snowflake-white";
            };
          }
          # Adding configuration to the widgets can also for example be used to
          # pin apps to the task-manager, which this example illustrates by
          # pinning dolphin and konsole to the task-manager by default.
          {
            name = "org.kde.plasma.icontasks";
            config = {
              General.launchers = [
                "applications:org.kde.dolphin.desktop"
                "applications:org.kde.konsole.desktop"
              ];
            };
          }
          # If no configuration is needed, specifying only the name of the
          # widget will add them with the default configuration.
          "org.kde.plasma.marginsseparator"
          # If you need configuration for your widget, instead of specifying the
          # the keys and values directly using the config attribute as shown
          # above, plasma-manager also provides some higher-level interfaces for
          # configuring the widgets. See modules/widgets for supported widgets
          # and options for these widgets. The widgets below shows two examples
          # of usage, one where we add a digital clock, setting 12h time and
          # first day of the week to sunday and another adding a systray with
          # some modifications in which entries to show.
          {
            digitalClock = {
              calendar.firstDayOfWeek = "monday";
              time.format = "12h";
            };
          }
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
      };
    };


    #
    # Some low-level settings:
    #
    configFile = {
      baloofilerc."Basic Settings"."Indexing-Enabled" = false;
      kwinrc."org.kde.kdecoration2".ButtonsOnLeft = "SF";
      kwinrc.Desktops.Number = {
        value = 8;
        # Forces kde to not change this value (even through the settings app).
        immutable = true;
      };
      kscreenlockerrc = {
        Greeter.WallpaperPlugin = "org.kde.potd";
        # To use nested groups use / as a separator. In the below example,
        # Provider will be added to [Greeter][Wallpaper][org.kde.potd][General].
        "Greeter/Wallpaper/org.kde.potd/General".Provider = "bing";
      };
    };
  };


  programs.konsole = {
    enable = true;
    profiles = {
      "Red-Flake" = {
        colorScheme = "Catppuccin-Mocha";
        command = "''${pkgs.zsh}/bin/zsh";
        font = {
          name = "Hack";
          size = 12;
        };
      }; 
    };
    defaultProfile = "Red-Flake";
  };

  xdg.dataFile."konsole/Catppuccin-Mocha.colorscheme".source =
    pkgs.fetchFromGitHub
      {
        owner = "catppuccin";
        repo = "konsole";
        rev = "7d86b8a1e56e58f6b5649cdaac543a573ac194ca";
        sha256 = "EwSJMTxnaj2UlNJm1t6znnatfzgm1awIQQUF3VPfCTM=";
      }
    + "/Catppuccin-Mocha.colorscheme";

}
