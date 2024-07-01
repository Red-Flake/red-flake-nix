{ config, lib, pkgs, inputs, ... }:

let
  logoPath = "${inputs.artwork}/logos";
  iconPath = "${inputs.artwork}/icons";
  wallpaperPath = "${inputs.artwork}/wallpapers";
in
{
  home.file.".red-flake/artwork/logos/" = {
    source = logoPath;
    recursive = true;
    force = true;
  };

  home.file.".local/share/icons/red-flake/" = {
    source = iconPath;
    recursive = true;
    force = true;
  };

  home.file.".local/share/wallpapers/red-flake/" = {
    source = wallpaperPath;
    recursive = true;
    force = true;
  };
}
