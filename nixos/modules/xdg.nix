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
}