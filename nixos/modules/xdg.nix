{ config, lib, pkgs, modulesPath, ... }: 

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
    extraPortals = [
      pkgs.xdg-desktop-portal
    ];
  };

  # if you use the NixOS module and have useUserPackages = true, make sure to add:
  environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];
}