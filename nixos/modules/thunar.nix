{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  programs.thunar.enable = true;
  programs.xfconf.enable = true; # Ensures preferences are saved
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true; # Provides mounting, trash support
  services.tumbler.enable = true; # Thumbnail support for images
}
