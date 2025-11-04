{
  config,
  lib,
  pkgs,
  ...
}:
{
  # deploy konsole profile
  home.file.".local/share/konsole/red-flake.profile" = {
    source = ./konsole/red-flake.profile;
    recursive = false;
    force = true;
  };

  # deploy konsolerc
  home.file.".config/konsolerc" = {
    source = ./konsole/konsolerc;
    recursive = false;
    force = true;
  };

  # deploy Sweet-Ambar-Blue colorscheme
  home.file.".local/share/konsole/Sweet-Ambar-Blue.colorscheme" = {
    source = ./konsole/Sweet-Ambar-Blue.colorscheme;
    recursive = false;
    force = true;
  };

  # deploy Kali-Dark colorscheme
  home.file.".local/share/konsole/Kali-Dark.colorscheme" = {
    source = ./konsole/Kali-Dark.colorscheme;
    recursive = false;
    force = true;
  };
}
