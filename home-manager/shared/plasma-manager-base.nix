# Parameterized plasma-manager base module
{ config
, lib
, pkgs
, osConfig
, ...
}:
let
  cfg = config.custom.plasma;

  # Map resolution settings to wallpaper filenames
  wallpaperFile =
    if cfg.wallpaperResolution == "auto" then
      {
        "1080p" = "Red-Flake-Wallpaper_1920x1080.png";
        "1440p" = "Red-Flake-Wallpaper_2560x1440.png";
        "1600p" = "Red-Flake-Wallpaper_2560x1600.png";
        "2160p" = "Red-Flake-Wallpaper_3840x2160.png";
      }.${osConfig.custom.display.resolution or "1080p"} or "Red-Flake-Wallpaper_1920x1080.png"
    else
      {
        "1080p" = "Red-Flake-Wallpaper_1920x1080.png";
        "1440p" = "Red-Flake-Wallpaper_2560x1440.png";
        "1600p" = "Red-Flake-Wallpaper_2560x1600.png";
        "2160p" = "Red-Flake-Wallpaper_3840x2160.png";
      }.${cfg.wallpaperResolution};

  wallpaperPath = "${config.home.homeDirectory}/.local/share/wallpapers/red-flake/${wallpaperFile}";

  waitForWaylandScript = pkgs.writeShellScript "wait-for-wayland" ''
    set -euo pipefail
    runtime="''${XDG_RUNTIME_DIR:-}"
    display="''${WAYLAND_DISPLAY:-wayland-0}"
    if [ -z "$runtime" ]; then
      exit 1
    fi
    for _ in {1..50}; do
      if [ -S "$runtime/$display" ]; then
        exit 0
      fi
      sleep 0.2
    done
    exit 1
  '';

  # Terminal hotkey configuration
  terminalHotkey =
    if cfg.terminal == "ghostty" then {
      "launch-ghostty" = {
        name = "Launch Ghostty";
        key = "Ctrl+Alt+T";
        command = "ghostty +new-window";
      };
    }
    else {
      "launch-konsole" = {
        name = "Launch Konsole";
        key = "Ctrl+Alt+T";
        command = "konsole";
      };
    };

  # Keyboard layout configuration
  keyboardLayouts = [
    {
      displayName = cfg.keyboardLayout;
      layout = cfg.keyboardLayout;
    }
  ];

  # KWin effects configuration
  kwinEffects = {
    dimInactive.enable = true;
    hideCursor = {
      enable = true;
      hideOnInactivity = 10;
      hideOnTyping = true;
    };
    blur.enable = !cfg.disableBlur;
    zoom.enable = false;
  };

  # Low-level kwin plugins config
  kwinPluginsConfig = lib.optionalAttrs cfg.disableBlur
    {
      "blurEnabled" = false;
    } // {
    "dimscreenEnabled" = true;
    "hidecursorEnabled" = true;
    "zoomEnabled" = false;
  };
in
{
  options.custom.plasma = {
    enable = lib.mkEnableOption "custom plasma configuration";

    terminal = lib.mkOption {
      type = lib.types.enum [ "ghostty" "konsole" ];
      default = "ghostty";
      description = "Terminal emulator to use for Ctrl+Alt+T hotkey.";
    };

    wallpaperResolution = lib.mkOption {
      type = lib.types.enum [ "1080p" "1440p" "1600p" "2160p" "auto" ];
      default = "auto";
      description = "Wallpaper resolution. Use 'auto' to detect from osConfig.custom.display.resolution.";
    };

    keyboardLayout = lib.mkOption {
      type = lib.types.str;
      default = "de";
      description = "Keyboard layout code (e.g., de, gb, us).";
    };

    taskbarApps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "applications:org.kde.dolphin.desktop"
        "applications:com.mitchellh.ghostty.desktop"
        "applications:firefox.desktop"
        "applications:code.desktop"
        "applications:burpsuitepro.desktop"
        "applications:ghidra.desktop"
        "applications:re.rizin.cutter.desktop"
        "applications:org.wireshark.Wireshark.desktop"
      ];
      description = "List of .desktop file applications to pin to the taskbar.";
    };

    enablePowerdevilService = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the Powerdevil systemd user service.";
    };

    strictMode = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable overrideConfig and immutableByDefault for plasma configs.";
    };

    autoLock = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable automatic screen locking.";
    };

    displayTimeouts = lib.mkOption {
      type = lib.types.attrsOf lib.types.int;
      default = { turnOff = 900; dim = 600; };
      description = "Display timeout settings in seconds.";
    };

    disableBlur = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Disable KWin blur effect (helps with high CPU usage on some Intel GPUs).";
    };

    enableTripleBuffering = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable KWin triple buffering.";
    };

    hideBrowserIntegrationReminder = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Hide the 'install Plasma Browser Integration' tray reminder.";
    };

    panelOpacity = lib.mkOption {
      type = lib.types.enum [ "opaque" "translucent" "adaptive" ];
      default = "opaque";
      description = "Panel opacity setting.";
    };

    windowRules = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [
        # BurpSuite Pro has a broken WM_CLASS (nix store path), so we force the desktopfile
        {
          description = "BurpSuite Professional window grouping";
          match = {
            window-types = [ "normal" ];
            title = {
              value = "Burp Suite Professional";
              type = "substring";
            };
          };
          apply = {
            desktopfile = {
              value = "burpsuitepro";
              apply = "force";
            };
          };
        }
      ];
      description = "KWin window rules for applications with broken WM_CLASS or custom behavior.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Powerdevil service
    systemd.user.services.plasma-powerdevil = lib.mkIf cfg.enablePowerdevilService {
      Unit = {
        Description = "KDE Powerdevil power-management daemon";
        PartOf = [ "graphical-session.target" ];
      };
      Install = {
        WantedBy = [ "plasma-workspace.target" ];
      };
      Service = {
        ExecStart = "${pkgs.kdePackages.powerdevil}/libexec/org_kde_powerdevil";
        ExecStartPre = "${waitForWaylandScript}";
        Type = "dbus";
        BusName = "org.kde.Solid.PowerManagement";
        Restart = "on-failure";
        RestartSec = "5s";
        Environment = [
          "QT_QPA_PLATFORM=wayland;xcb"
        ];
      };
    };

    programs.plasma = {
      enable = true;
      overrideConfig = cfg.strictMode;
      immutableByDefault = cfg.strictMode;

      window-rules = cfg.windowRules;

      workspace = {
        clickItemTo = "open";
        theme = "default";
        colorScheme = "GradientDarkColorScheme";
        cursor = {
          theme = "Sweet-cursors";
          size = 24;
        };
        windowDecorations.library = "org.kde.breeze";
        windowDecorations.theme = "Breeze";
        iconTheme = "Papirus-Dark";
        wallpaper = wallpaperPath;
      };

      kwin = {
        virtualDesktops = {
          rows = 1;
          number = 8;
        };
        effects = kwinEffects;
      };

      hotkeys.commands = terminalHotkey;

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
          opacity = cfg.panelOpacity;
          widgets = [
            {
              name = "org.kde.plasma.kickoff";
              config = {
                General.icon = "${config.home.homeDirectory}/.red-flake/artwork/logos/RedFlake_Logo_32x32px.png";
              };
            }
            {
              name = "org.kde.plasma.icontasks";
              config = {
                General = {
                  showOnlyCurrentDesktop = "false";
                  showOnlyCurrentActivity = "true";
                  showOnlyCurrentScreen = "true";
                  launchers = cfg.taskbarApps;
                };
              };
            }
            "org.kde.plasma.marginsseparator"
            "org.kde.plasma.pager"
            {
              systemTray.items = {
                shown = [
                  "org.kde.plasma.networkmanagement"
                  "org.kde.plasma.volume"
                  "org.kde.plasma.battery"
                  "org.kde.plasma.bluetooth"
                  "org.kde.plasma.systemtray"
                ];
                hidden = [
                  "org.kde.plasma.brightness"
                ] ++ lib.optionals cfg.hideBrowserIntegrationReminder [
                  "org.kde.plasma.browser_integration"
                  "org.kde.plasma.browserintegration"
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
          floating = false;
          height = 26;
          opacity = cfg.panelOpacity;
          widgets = [
            "org.kde.plasma.appmenu"
          ];
        }
      ];

      shortcuts = {
        ksmserver = {
          "Lock Session" = [
            "Screensaver"
            "Ctrl+Alt+L"
          ];
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

      kscreenlocker = {
        appearance.wallpaper = wallpaperPath;
        inherit (cfg) autoLock;
      };

      powerdevil = {
        battery = {
          autoSuspend = {
            action = "nothing";
            idleTimeout = null;
          };
          turnOffDisplay.idleTimeout = cfg.displayTimeouts.turnOff;
          dimDisplay = {
            enable = true;
            idleTimeout = cfg.displayTimeouts.dim;
          };
        };
        AC = {
          autoSuspend = {
            action = "nothing";
            idleTimeout = null;
          };
          turnOffDisplay.idleTimeout = cfg.displayTimeouts.turnOff;
          dimDisplay = {
            enable = true;
            idleTimeout = cfg.displayTimeouts.dim;
          };
        };
      };

      input.keyboard.layouts = keyboardLayouts;

      session = {
        sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";
      };

      configFile = {
        "kdeglobals"."General"."AccentColor" = "160,31,52";
        "kdeglobals"."KDE"."AnimationDurationFactor" = 0.5;
        "kwinrc" = {
          "org.kde.kdecoration2"."ButtonsOnLeft" = "SF";
          "Desktops"."Number" = {
            value = 8;
            immutable = true;
          };
          "Effect-hidecursor" = {
            "HideOnTyping" = true;
            "InactivityDuration" = 10;
          };
          "Plugins" = kwinPluginsConfig;
          "Compositing" = lib.mkIf cfg.enableTripleBuffering {
            "TripleBuffering" = true;
          };
        };
      };
    };
  };
}
