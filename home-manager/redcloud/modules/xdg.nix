{ pkgs, ... }:

{
  # enable xdg desktop portal
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-gtk
    ];
    configPackages = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
    ];
  };

  # enable XDG mime
  xdg.mime = { enable = true; };
}
