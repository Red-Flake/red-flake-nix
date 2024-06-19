{ config, lib, pkgs, ... }:
{
    # deploy konsole profile
    home.file.".local/share/konsole/red-flake.profile" = {
      source = ./konsole/red-flake.profile;
      recursive = false;
    };

    # deploy konsolerc
    home.file.".config/konsolerc" = {
      source = ./konsole/konsolerc;
      recursive = false;
    };

    # deploy Sweet-Ambar-Blue colorscheme
    home.file.".local/share/konsole/Sweet-Ambar-Blue.colorscheme" = {
      source = ./konsole/Sweet-Ambar-Blue.colorscheme;
      recursive = false;
    };
}