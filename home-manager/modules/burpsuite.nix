{ config, lib, pkgs, ... }:
{
    # deploy UserConfigCommunity.json
    home.file.".BurpSuite/UserConfigCommunity.json" = {
      source = ./burpsuite/UserConfigCommunity.json;
      recursive = false;
      force = true;
    };
}
