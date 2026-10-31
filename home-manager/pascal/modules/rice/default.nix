# Red Flake Noir: pascal's desktop rice.
#
# Near-black surfaces, crimson/ember accents, a top bar plus a macOS-style
# floating dock, the Darkly app style and window decoration, Papirus icons with red folders,
# Bibata cursors, Inter for the UI and Maple Mono for code.
#
# Everything here is pascal-only. The shared modules (plasma-manager-base.nix,
# theme.nix, ghostty.nix, vscode, equibop, firefox) stay as they are for the
# other users; this module overrides them on top.
#
#   palette.nix      the colors, used by all files below
#   colorscheme.nix  KDE color scheme (GTK follows through KDE's GTK sync)
#   terminal.nix     Ghostty theme (Starship/fastfetch inherit the ANSI colors)
#   apps.nix         VS Code, Equibop and Firefox colors
#
# The SDDM login screen is themed separately per host:
# nixos/hosts/stellaris/sddm-theme.nix
{ config
, lib
, pkgs
, ...
}:
let
  p = import ./palette.nix { inherit lib; };
  cfg = config.custom.plasma;

  # theme.nix already uses mkForce for some of these, so win over that
  force = lib.mkOverride 40;

  wallpaperName = "red-flake-noir-echo-2560x1600.png";
  wallpaper = "${config.home.homeDirectory}/.local/share/wallpapers/red-flake-noir/${wallpaperName}";

  # Papirus-Dark with muted wine-red folders: Papirus' "carmine" folders,
  # recolored to the palette (stock carmine is too loud for the theme).
  # hiPrio: the shared package list also installs plain Papirus for everyone,
  # and this copy has to win where the two overlap.
  icons = {
    name = "Papirus-Dark";
    package = lib.hiPrio (
      (pkgs.papirus-icon-theme.override { color = "carmine"; }).overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          find $out/share/icons -type f -name '*carmine*.svg' -exec sed -i \
            -e 's/#a30002/${p.folder}/g' \
            -e 's/#7a0002/${p.folderBack}/g' \
            -e 's/#390001/${p.folderInk}/g' {} +
        '';
      })
    );
  };

  # Plasma style "red-flake-noir": Breeze plus a macOS-style dock, i.e. a
  # rounded dock background (plasma-style/make-panel-svg.py, one per Breeze
  # variant: plain, blurred, opaque) and dots under running apps
  # (plasma-style/make-tasks-svg.py). Everything else falls back to Breeze.
  plasmaStyle =
    let
      breeze = "${pkgs.kdePackages.libplasma}/share/plasma/desktoptheme/default";
      # Breeze file, dock fill opacity
      panelVariants = {
        "widgets" = "0.9";
        "translucent/widgets" = "0.75"; # with blur behind it
        "solid/widgets" = "1";
      };
    in
    pkgs.runCommand "plasma-style-red-flake-noir" { nativeBuildInputs = [ pkgs.python3 ]; } ''
      mkdir -p $out/widgets
      cp ${./plasma-style/metadata.json} $out/metadata.json
      cp ${./plasma-style/plasmarc} $out/plasmarc
      gzip -dc ${breeze}/widgets/tasks.svgz > breeze-tasks.svg
      python3 -I ${./plasma-style/make-tasks-svg.py} breeze-tasks.svg $out/widgets/tasks.svg '${p.crimson}'
      ${lib.concatStrings (lib.mapAttrsToList (dir: opacity: ''
        mkdir -p $out/${dir}
        gzip -dc ${breeze}/${dir}/panel-background.svgz > panel.svg
        python3 -I ${./plasma-style/make-panel-svg.py} panel.svg $out/${dir}/panel-background.svg ${opacity}
      '') panelVariants)}
    '';

  # Installed as real files, not home-manager symlinks: Plasma refuses widget
  # files that link out of the widget's folder, and caches theme SVGs by path
  # and modification time (always 1970 in the Nix store), so a changed SVG
  # would never show. Copied again only when the source changes, which gives
  # the files a new modification time.
  realFiles = {
    desktoptheme = {
      src = plasmaStyle;
      dst = ".local/share/plasma/desktoptheme/red-flake-noir";
    };
    workspaces = {
      src = "${./plasmoids/workspaces}"; # top bar widget
      dst = ".local/share/plasma/plasmoids/org.redflake.workspaces";
    };
  };

  cursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
  };

  uiFont = "Inter";
  monoFont = "Maple Mono NF";

  logo = "${config.home.homeDirectory}/.red-flake/artwork/logos/RedFlake_Logo_64x64px.png";

  # strictMode (plasma-manager's overrideConfig) wipes kdeglobals on every
  # rebuild and only keeps the color groups plasma-manager knows about. That
  # list misses the title bar colors ([Colors:Header], [WM]) and
  # [Colors:Complementary], and has a typo for ForegroundPositive. Without
  # them KWin paints active title bars in the accent color until the next
  # login. Mark the rest as persistent so a rebuild keeps them.
  colorKeys = [
    "BackgroundAlternate"
    "BackgroundNormal"
    "DecorationFocus"
    "DecorationHover"
    "ForegroundActive"
    "ForegroundInactive"
    "ForegroundLink"
    "ForegroundNegative"
    "ForegroundNeutral"
    "ForegroundNormal"
    "ForegroundPositive"
    "ForegroundVisited"
  ];
  keep = keys: lib.genAttrs keys (_: { persistent = true; });
  colorSchemePersistence.kdeglobals = {
    "Colors:Header" = keep colorKeys;
    "Colors:Header/Inactive" = keep colorKeys;
    "Colors:Complementary" = keep colorKeys;
    "Colors:Button" = keep [ "ForegroundPositive" ];
    "Colors:Selection" = keep [ "ForegroundPositive" ];
    "Colors:Tooltip" = keep [ "ForegroundPositive" ];
    "Colors:View" = keep [ "ForegroundPositive" ];
    "Colors:Window" = keep [ "ForegroundPositive" ];
    WM = keep [
      "activeBackground"
      "activeBlend"
      "activeForeground"
      "inactiveBackground"
      "inactiveBlend"
      "inactiveForeground"
    ];
  };

  colorSchemeText = import ./colorscheme.nix { inherit p; };

  gtkSettings = {
    gtk-icon-theme-name = force icons.name;
    gtk-cursor-theme-name = force cursor.name;
    gtk-cursor-theme-size = force cursor.size;
    gtk-font-name = force "${uiFont} 11";
  };
in
{
  imports = [
    ./terminal.nix
    ./apps.nix
  ];

  _module.args.ricePalette = p;

  home.packages = [
    pkgs.darkly # Qt app style + window decoration
    pkgs.inter
    pkgs.maple-mono.NF
    icons.package
    cursor.package

    # `qdbus6` as many KDE docs/scripts call it (e.g. qdbus6 org.kde.KWin /KWin
    # reconfigure). Qt 6 on NixOS only ships it as `qdbus`, which the system
    # already has.
    (pkgs.runCommand "qdbus6" { } ''
      mkdir -p $out/bin
      ln -s ${pkgs.kdePackages.qttools}/bin/qdbus $out/bin/qdbus6
    '')
  ];

  home.file.".local/share/wallpapers/red-flake-noir/${wallpaperName}".source =
    ../../../../assets/wallpapers/${wallpaperName};

  home.file.".local/share/color-schemes/RedFlakeNoir.colors".text = colorSchemeText;

  # See realFiles. A symlink per target remembers which source was copied.
  # Runs before applyPlasmaNow (../plasma-manager.nix) applies the style.
  home.activation.riceRealFiles = lib.hm.dag.entryBetween [ "applyPlasmaNow" ] [ "linkGeneration" ] (
    ''
      stamps="${config.xdg.stateHome}/red-flake-rice"
      run mkdir -p "$stamps"
    ''
    + lib.concatStrings (
      lib.mapAttrsToList
        (name: f: ''
          dst="${config.home.homeDirectory}/${f.dst}"
          if [ "$(readlink "$stamps/${name}" 2>/dev/null)" != "${f.src}" ] || [ ! -e "$dst/metadata.json" ]; then
            verboseEcho "Installing ${f.dst}"
            run rm -rf "$dst"
            run mkdir -p "$dst"
            run cp -rT --no-preserve=mode,ownership,timestamps "${f.src}" "$dst"
            run ln -sfn "${f.src}" "$stamps/${name}"
          fi
        '')
        realFiles
    )
  );

  # plasma-manager only re-applies the scheme when its name changes. This runs
  # at the next login after the colors change (the hash changes the script),
  # and goes through Breeze Dark because Plasma skips re-applying the scheme
  # that is already active.
  programs.plasma.startup.startupScript."rice_colorscheme" = {
    priority = 2;
    text = ''
      # Red Flake Noir colors: ${builtins.hashString "sha256" colorSchemeText}
      plasma-apply-colorscheme BreezeDark >/dev/null
      plasma-apply-colorscheme RedFlakeNoir
    '';
  };

  # Same for the Plasma style: a running Plasma keeps showing the old dock
  # SVGs until the style is applied again, and Plasma skips that when the style
  # is already active. A fresh login doesn't need it, but it's harmless there.
  programs.plasma.startup.startupScript."rice_desktoptheme" = {
    priority = 2;
    text = ''
      # Red Flake Noir style: ${plasmaStyle}
      plasma-apply-desktoptheme default >/dev/null
      plasma-apply-desktoptheme red-flake-noir
    '';
  };

  # ---------------------------------------------------------------- Plasma
  programs.plasma = {
    workspace = {
      colorScheme = lib.mkForce "RedFlakeNoir";
      theme = lib.mkForce "red-flake-noir"; # Plasma style, see plasmaStyle
      widgetStyle = "Darkly";
      iconTheme = lib.mkForce icons.name;
      cursor = lib.mkForce {
        theme = cursor.name;
        inherit (cursor) size;
      };
      windowDecorations = {
        library = lib.mkForce "org.kde.darkly";
        theme = lib.mkForce "Darkly";
      };
      wallpaper = lib.mkForce wallpaper;
    };

    fonts = lib.mkForce {
      general = {
        family = uiFont;
        pointSize = 10.5;
      };
      fixedWidth = {
        family = monoFont;
        pointSize = 11;
      };
      small = {
        family = uiFont;
        pointSize = 9;
      };
      toolbar = {
        family = uiFont;
        pointSize = 10;
      };
      menu = {
        family = uiFont;
        pointSize = 10;
      };
      windowTitle = {
        family = uiFont;
        pointSize = 10.5;
        weight = "demiBold";
      };
    };

    kwin.effects = {
      blur = {
        strength = 8;
        noiseStrength = 2;
      };
      minimization.animation = "magiclamp";
      windowOpenClose.animation = "glide";
    };

    kscreenlocker.appearance.wallpaper = lib.mkForce wallpaper;

    # Top bar + macOS-style dock (replaces the bottom taskbar and the
    # global-menu strip from the shared base module)
    panels = lib.mkForce [
      {
        location = "top";
        floating = false; # attached to the screen edge; only the dock floats
        height = 34;
        lengthMode = "fill";
        opacity = "translucent";
        hiding = "normalpanel";
        widgets = [
          {
            name = "org.kde.plasma.kickoff";
            config.General.icon = logo;
          }
          "org.kde.plasma.appmenu"
          { panelSpacer.expanding = true; }
          {
            digitalClock = {
              calendar = {
                firstDayOfWeek = "sunday";
              } // lib.optionalAttrs (cfg.calendarPlugins != [ ]) {
                plugins = cfg.calendarPlugins;
              };
              time.format = "12h";
              # Fixed size: the automatic size fills the panel height and is
              # too large. Weight uses Qt 6's scale (400 = normal); the widget's
              # default of 50 would be nearly hairline thin.
              font = {
                family = uiFont;
                size = 10;
                weight = 500;
              };
              date = {
                enable = true;
                format.custom = "ddd d MMM";
                position = "besideTime";
              };
            };
          }
          { panelSpacer.expanding = true; }
          # Workspaces with their windows (plasmoids/workspaces): click to
          # switch, drag a window icon onto another workspace to move it
          "org.redflake.workspaces"
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
        ];
      }
      {
        # The dock: centered, only as wide as its icons. Its look (round
        # corners, dots under running apps) comes from the Plasma style.
        # make-tasks-svg.py assumes the task width this height gives.
        location = "bottom";
        floating = true;
        height = 56;
        lengthMode = "fit";
        alignment = "center";
        opacity = "translucent";
        # Moves out of the way when a window touches it
        hiding = "dodgewindows";
        widgets = [
          {
            name = "org.kde.plasma.icontasks";
            config.General = {
              showOnlyCurrentDesktop = "false";
              showOnlyCurrentActivity = "true";
              showOnlyCurrentScreen = "true";
              launchers = cfg.taskbarApps;
              iconSpacing = 2;
              maxStripes = 1;
            };
          }
        ];
      }
    ];

    configFile = lib.mkMerge [
      colorSchemePersistence
      {
        "kdeglobals"."General"."AccentColor" = lib.mkForce (p.rgb p.wine);
        # Darkly app style and window decoration (one file for both)
        "darklyrc" = {
          Common = {
            # Off: the floating title bar is a separate rounded "pill" with a
            # gap above the window, which looks detached
            FloatingTitlebar = false;
            CornerRadius = 10;
            ShadowSize = "ShadowLarge";
            ShadowStrength = 180;
            OutlineCloseButton = false;
          };
          Windeco = {
            TitleAlignment = "AlignCenterFullWidth";
            ButtonSize = "ButtonDefault";
            DrawBorderOnMaximizedWindows = false;
            DrawTitleBarSeparator = false;
            DrawBackgroundGradient = false;
          };
          Style = {
            # Translucent menus need KWin blur (custom.plasma.disableBlur = false)
            MenuOpacity = 88;
            TabDrawHighlight = true;
            TabUseHighlightColor = true;
            AnimationsDuration = 180;
          };
        };
      }
    ];
  };

  # ------------------------------------------------------------------- GTK
  gtk = {
    iconTheme = force icons;
    cursorTheme = force cursor;
    gtk3.extraConfig = gtkSettings;
    gtk4.extraConfig = gtkSettings;
    # KDE writes the color scheme to gtk-4.0/colors.css, but the gtk.css that
    # home-manager writes doesn't load it. GTK3 already imports it.
    gtk4.extraCss = "@import 'colors.css';";
  };

  dconf.settings."org/gnome/desktop/interface" = {
    icon-theme = force icons.name;
    cursor-theme = force cursor.name;
    cursor-size = force cursor.size;
    font-name = "${uiFont} 11";
    monospace-font-name = "${monoFont} 11";
    accent-color = "red";
  };

  home.pointerCursor = {
    name = force cursor.name;
    package = force cursor.package;
    size = force cursor.size;
  };

  xresources.properties."Xcursor.theme" = force cursor.name;
}
