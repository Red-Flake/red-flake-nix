{ config, lib, pkgs, ... }:
{
    # deploy dolphinrc
    home.file.".config/dolphinrc" = {
      source = ./dolphin/dolphinrc;
      recursive = false;
      force = true;
    };
}
