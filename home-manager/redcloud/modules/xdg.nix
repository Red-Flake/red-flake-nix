{ config, lib, pkgs, ... }: 

{
# enable xdg desktop portal
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-kde
    ];
    configPackages = with pkgs; [
      xdg-desktop-portal-kde
    ];
  };

  # enable XDG mime
  xdg.mime = { enable = true; };
}