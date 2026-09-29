{ lib, pkgs, ... }:
let
  desktopPlugin = import ./plugin { inherit pkgs; };
  desktop = import ./desktop.nix { inherit pkgs; };
  windowAction = action: "${lib.getExe desktop} action ${action}";
  noctalia = command: "noctalia msg ${command}";
  # 96 dpi × the panel's 1.6 scale; XWayland apps (Equibop, Steam, …) size their UI from it.
  xresources = pkgs.writeText "stellaris-xresources" "Xft.dpi: 153\n";
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    configType = "lua";
    systemd.enable = false; # UWSM owns session startup and teardown.
    extraConfig = ''
      hl.plugin.load("${desktopPlugin}/lib/libstellaris-desktop.so")
      hl.plugin.load("${pkgs.hyprlandPlugins.hyprbars}/lib/libhyprbars.so")
      -- Plugins load after the initial parse and request a config reload.
      if hl.plugin.hyprbars then
        hl.config({ plugin = { hyprbars = {
          bar_height = 30, bar_color = "rgb(171b27)",
          bar_text_font = "Noto Sans", bar_text_size = 12,
          bar_buttons_alignment = "left", bar_part_of_window = true,
          bar_padding = 10, bar_button_padding = 7, icon_on_hover = true,
          on_double_click = "${windowAction "maximize"}",
        } } })
        local buttons = {
          { "ff605c", "×", "close" }, { "ffbd44", "−", "minimize" }, { "00ca4e", "+", "maximize" },
        }
        for _, button in ipairs(buttons) do
          hl.plugin.hyprbars.add_button({ bg_color = "rgb(" .. button[1] .. ")",
            fg_color = "rgb(171b27)", size = 14, icon = button[2],
            action = "${windowAction ""}" .. button[3] })
        end
        -- The Stellaris plugin tags windows that draw their own titlebar (GTK, Electron, Firefox).
        hl.window_rule({ name = "no-bar-on-csd", match = { tag = "stellaris-csd" }, ["hyprbars:no_bar"] = true })
        -- GTK4 never requests server-side decorations, but Ghostty runs with
        -- gtk-titlebar = false (KWin draws its titlebar in Plasma), so it needs the bar.
        -- Later rules win; add other headerbar-less GTK4 apps here.
        hl.window_rule({ name = "bar-on-ghostty", match = { class = "com\\.mitchellh\\.ghostty" }, ["hyprbars:no_bar"] = false })
      end
      hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
      hl.config({
        general = {
          layout = "dwindle", border_size = 2, gaps_in = 6, gaps_out = 12,
          resize_on_border = true,
          col = { active_border = "rgba(65d5c2ee)", inactive_border = "rgba(444b6099)" },
        },
        input = {
          kb_layout = "de", follow_mouse = 0,
          touchpad = { natural_scroll = false, tap_to_click = true },
        },
        decoration = {
          rounding = 0,
          blur = { enabled = true, size = 6, passes = 2 },
          shadow = { enabled = true, range = 20, render_power = 3, color = "rgba(00000055)" },
        },
        animations = { enabled = true },
        dwindle = { preserve_split = true },
        misc = { disable_hyprland_logo = true, disable_splash_rendering = true },
        ecosystem = { no_update_news = true, no_donation_nag = true },
        -- Like Plasma's "apply scaling themselves": X11 apps render at native resolution
        -- and scale from Xft.dpi (loaded at start), instead of being upscaled and blurry.
        xwayland = { force_zero_scaling = true },
        -- Focusing a window (dock, window switcher) leaves the pointer where it is, as in Plasma.
        cursor = { no_warps = true },
      })
      hl.window_rule({ name = "floating-default", match = { class = ".*" }, float = true })
      -- Hyprland's maximize is a fullscreen mode that captures every click inside it, so
      -- windows on top of it could not be focused. App requests go to stellaris-desktop,
      -- which maximizes KDE-style (resize to the free area, restore the old geometry).
      hl.window_rule({ name = "kde-style-maximize", match = { class = ".*" }, suppress_event = "maximize" })
      hl.curve("desktop", { type = "bezier", points = { {0.16, 1}, {0.3, 1} } })
      hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "desktop", style = "popin 92%" })
      hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "desktop" })
      hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "desktop", style = "slide" })
      hl.animation({ leaf = "layers", enabled = true, speed = 3, bezier = "desktop", style = "fade" })
      hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

      hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("ghostty +new-window"))
      hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd("ghostty +new-window"))
      -- Previous/next workspace on this monitor (including empty ones), like the swipe.
      hl.bind("CTRL + ALT + left", hl.dsp.focus({ workspace = "r-1" }))
      hl.bind("CTRL + ALT + right", hl.dsp.focus({ workspace = "r+1" }))
      hl.bind("SUPER + E", hl.dsp.exec_cmd("dolphin"))
      hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("${noctalia "panel-toggle launcher"}"))
      hl.bind("ALT + F4", hl.dsp.window.close())
      hl.bind("SUPER + F", hl.dsp.exec_cmd("${windowAction "maximize"}"))
      hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen())
      hl.bind("SUPER + T", hl.dsp.window.float({ action = "toggle" }))
      hl.bind("SUPER + M", hl.dsp.exec_cmd("${windowAction "minimize"}"))
      hl.bind("SUPER + SHIFT + M", hl.dsp.workspace.toggle_special("minimized"))
      hl.bind("ALT + TAB", hl.dsp.exec_cmd("${noctalia "window-switcher"}"))
      hl.bind("ALT + SHIFT + TAB", hl.dsp.window.cycle_next({ next = false }))
      hl.bind("SUPER + L", hl.dsp.exec_cmd("${noctalia "session lock"}"))
      hl.bind("SUPER + S", hl.dsp.exec_cmd("${noctalia "panel-toggle control-center"}"))
      hl.bind("SUPER + COMMA", hl.dsp.exec_cmd("${noctalia "settings-toggle"}"))
      hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
      hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
      for i = 1, 9 do
        hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
        hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
      end
      local media = {
        -- Noctalia's commands also show its on-screen display.
        XF86AudioRaiseVolume = "${noctalia "volume-up"}",
        XF86AudioLowerVolume = "${noctalia "volume-down"}",
        XF86AudioMute = "${noctalia "volume-mute"}",
        XF86AudioMicMute = "${noctalia "mic-mute"}",
        XF86MonBrightnessUp = "${noctalia "brightness-up"}",
        XF86MonBrightnessDown = "${noctalia "brightness-down"}",
        XF86AudioPlay = "${pkgs.playerctl}/bin/playerctl play-pause",
        XF86AudioNext = "${pkgs.playerctl}/bin/playerctl next",
        XF86AudioPrev = "${pkgs.playerctl}/bin/playerctl previous",
      }
      for key, command in pairs(media) do
        hl.bind(key, hl.dsp.exec_cmd(command), { locked = true, repeating = true })
      end
      hl.bind("Print", hl.dsp.exec_cmd("${noctalia "screenshot-region"}"))

      -- Noctalia shell (bar, dock, launcher, notifications, lock screen, idle), started
      -- through UWSM so it runs in the user manager as upstream expects.
      hl.on("hyprland.start", function()
        hl.exec_cmd("${lib.getExe pkgs.xrdb} -merge ${xresources}")
        hl.exec_cmd("${pkgs.uwsm}/bin/uwsm app -- noctalia")
      end)
      -- Blur for Noctalia's surfaces; Noctalia animates them itself (upstream Hyprland docs).
      hl.layer_rule({
        name = "noctalia",
        match = { namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$" },
        no_anim = true,
        ignore_alpha = 0.5,
        blur = true,
        blur_popups = true,
      })
      hl.window_rule({ name = "noctalia-settings", match = { class = "dev\\.noctalia\\.Noctalia" }, size = { 1080, 920 } })
    '';
  };
}
