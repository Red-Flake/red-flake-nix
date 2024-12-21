{ config, lib, pkgs, ... }:
{
    # deploy dolphinrc
    home.file.".config/dolphinrc" = {
      source = ./dolphin/dolphinrc;
      recursive = false;
      force = true;
    };

    # deploy dolphinstaterc
    home.file.".local/share/dolphin/dolphinstaterc" = {
      source = ./dolphin/dolphinstaterc;
      recursive = false;
      force = true;
    };
}
