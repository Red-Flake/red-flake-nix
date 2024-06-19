{ config, lib, pkgs, ... }:
{
    home.file.".red-flake/artwork/logos/" = {
      source = ../../artwork/logos;
      recursive = true;
      force = true;
    };
}