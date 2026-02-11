{ pkgs, ... }:

{
  # enable xdg desktop portal
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

  # enable XDG mime
  xdg.mime = { enable = true; };
}
