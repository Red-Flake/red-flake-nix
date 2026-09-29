{ config, lib, pkgs, inputs, ... }:
let
  target = "wayland-session@hyprland.desktop.target";
  desktop = import ./desktop.nix { inherit pkgs; };
  wallpaper = "${inputs.artwork}/wallpapers/Red-Flake-Wallpaper_2560x1600.png";
  noctalia = config.programs.noctalia.package;
  # Read-only Noctalia plugin source: one subdirectory per plugin id suffix.
  noctaliaPlugins = pkgs.runCommand "stellaris-noctalia-plugins" { } ''
    mkdir -p "$out/appmenu"
    cp ${./noctalia-appmenu}/* "$out/appmenu/"
    sed -i 's|@desktop@|${lib.getExe desktop}|g' "$out"/appmenu/*.luau
    if grep -r '@desktop@' "$out"; then exit 1; fi
    ${lib.getExe noctalia} plugins lint "$out/appmenu"
    cat > "$out/catalog.toml" <<'EOF'
    [[plugin]]
    id = "stellaris/appmenu"
    name = "App menu"
    version = "1.0.0"
    plugin_api = 24
    EOF
  '';
  noctaliaSettings = {
    theme = {
      mode = "dark";
      source = "builtin";
      builtin = "Noctalia";
      # Do not write colour configs for other apps; they are shared with Plasma.
      templates = {
        enable_builtin_templates = false;
        enable_community_templates = false;
      };
    };
    shell = {
      setup_wizard_enabled = false;
      telemetry_enabled = false;
      font_family = "Noto Sans";
      # Noctalia runs through `uwsm app`, so apps it launches get their own units.
      launch_apps_as_systemd_services = true;
      panel.transparency_mode = "soft";
    };
    weather.enabled = false;
    wallpaper = {
      enabled = true;
      default.path = wallpaper;
    };
    bar.default = squareCorners // {
      position = "top";
      margin_ends = 0;
      background_opacity = 0.85;
      start = [ "launcher" "appmenu" ];
      center = [ "workspaces" ];
      end = [ "tray" "notifications" "network" "bluetooth" "volume" "brightness" "battery" "control-center" "clock" ];
    };
    widget = {
      appmenu.type = "stellaris/appmenu:menu";
      # Icon only; the SSID is in the tooltip and the Wi-Fi panel.
      network.show_label = false;
    };
    dock = squareCorners // {
      enabled = true;
      position = "bottom";
      margin_edge = 6;
      show_dots = true;
      pinned = [ "org.kde.dolphin" "com.mitchellh.ghostty" "firefox-nightly" ];
    };
    idle.behavior = {
      lock = { enabled = true; action = "lock"; timeout = 300; };
      screen-off = { enabled = true; action = "screen_off"; timeout = 600; };
    };
    plugins = {
      enabled = [ "stellaris/appmenu" ];
      auto_update = "none";
      source = [{
        name = "stellaris";
        kind = "path";
        location = "${noctaliaPlugins}";
        enabled = true;
      }];
    };
  };
  # Noctalia only warns about unknown keys or plugins it has to skip; treat that as an error.
  noctaliaConfig = pkgs.runCommand "noctalia-config.toml" { } ''
    result=$(${lib.getExe noctalia} config validate ${(pkgs.formats.toml { }).generate "config.toml" noctaliaSettings} 2>&1) || { echo "$result"; exit 1; }
    echo "$result"
    if echo "$result" | grep -Eq 'WRN|warning'; then exit 1; fi
    cp ${(pkgs.formats.toml { }).generate "config.toml" noctaliaSettings} "$out"
  '';
  sessionService = executable: {
    Unit = {
      After = [ target ];
      PartOf = [ target ];
      ConditionEnvironment = "XDG_CURRENT_DESKTOP=Hyprland";
    };
    Service = {
      ExecStart = executable;
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ target ];
  };
  squareCorners = {
    radius = 0;
    radius_top_left = 0;
    radius_top_right = 0;
    radius_bottom_left = 0;
    radius_bottom_right = 0;
    concave_edge_corners = false;
  };
in
{
  imports = [
    ./hyprland.nix
    inputs.noctalia.homeModules.default
  ];
  home.packages = with pkgs; [
    desktop
    kdePackages.qt6ct
  ];

  # UWSM imports and cleans these variables with this session only.
  xdg.configFile."uwsm/env-hyprland".text = ''
    export QT_QPA_PLATFORMTHEME=qt6ct
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
    export XCURSOR_THEME=Sweet-cursors
    export XCURSOR_SIZE=24
  '';
  # qt6ct also makes Qt apps export their menus to the global app menu.
  xdg.configFile."qt6ct/qt6ct.conf".text = ''
    [Appearance]
    style=Breeze
    icon_theme=Papirus-Dark
    custom_palette=true
    color_scheme_path=${pkgs.kdePackages.qt6ct}/share/qt6ct/colors/darker.conf
    [Fonts]
    fixed="JetBrains Mono,11,-1,5,50,0,0,0,0,0"
    general="Noto Sans,11,-1,5,50,0,0,0,0,0"
  '';

  # Bar, dock, launcher, control center, notifications, OSD, lock screen and idle.
  # Started by Hyprland (see hyprland.nix), as upstream recommends.
  programs.noctalia = {
    enable = true;
    settings = noctaliaSettings;
    # Replaced below by a stricter check that also fails on warnings.
    checkConfig = false;
  };

  xdg.configFile."noctalia/config.toml".source = lib.mkForce noctaliaConfig;

  # Home Manager's tray.target (pulled in by udiskie) otherwise stays active after a
  # Plasma logout and keeps graphical-session-pre.target alive; UWSM then refuses to
  # start Hyprland ("A compositor or graphical-session* target is already active").
  systemd.user.targets.tray.Unit.StopWhenUnneeded = true;

  # Session-scoped so they never run next to Plasma's own agents.
  systemd.user.services.stellaris-desktop = sessionService "${lib.getExe desktop} serve";
  systemd.user.services.stellaris-polkit = sessionService "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
}
