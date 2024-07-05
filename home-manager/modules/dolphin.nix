{ config, lib, pkgsx86_64_v3, ... }:
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
