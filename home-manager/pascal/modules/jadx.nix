{ config, lib, pkgs, ... }:
{
    # deploy .config/jadx/gui.json
    home.file.".config/jadx/gui.json" = {
      source = ./dolphin/dolphinrc;
      recursive = false;
      force = true;
    };
}
