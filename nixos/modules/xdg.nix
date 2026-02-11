{ pkgs
, ...
}:

{
  # enable dconf
  # Fix GTK themes not applied in Wayland
  programs.dconf.enable = true;

  # enable XDG Desktop Menu specification
  xdg.menus.enable = true;

  # enable XDG autostart
  xdg.autostart.enable = true;

  # enable XDG icons
  xdg.icons.enable = true;

  # enable XDG sounds
  xdg.sounds.enable = true;

  # enable XDG terminal exec
  xdg.terminal-exec.enable = true;

  # XDG portal settings
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-gtk # Fallback for DPI/apps
    ];
    configPackages = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    config = {
      common = {
        default = [ "kde" "gtk" ];
      };
      plasma = {
        # Matches $XDG_CURRENT_DESKTOP=plasma
        default = [ "kde" "gtk" ];
        "org.freedesktop.impl.portal.Inhibit" = [ "kde" ]; # Targets CreateMonitor error
      };
    };
  };

  # if you use the NixOS module and have useUserPackages = true, make sure to add:
  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];
}
