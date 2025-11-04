{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
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
  # TODO: fix this!
  #  evaluation warning: xdg-desktop-portal 1.17 reworked how portal implementations are loaded, you
  #  should either set `xdg.portal.config` or `xdg.portal.configPackages`
  #  to specify which portal backend to use for the requested interface.
  #
  #  https://github.com/flatpak/xdg-desktop-portal/blob/1.18.1/doc/portals.conf.rst.in
  #
  # If you simply want to keep the behaviour in < 1.17, which uses the first
  # portal implementation found in lexicographical order, use the following:
  #
  #  xdg.portal.config.common.default = "*";
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal
    ];
  };

  # if you use the NixOS module and have useUserPackages = true, make sure to add:
  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];
}
