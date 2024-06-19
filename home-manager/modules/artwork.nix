{ config, lib, pkgs, ... }:
{
    home.file.".red-flake/logos/" = {
      source = ./konsole/red-flake.profile;
      recursive = false;
      force = true;
    };
}