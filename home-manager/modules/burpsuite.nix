{ config, lib, pkgsx86_64_v3, ... }:
{
    # deploy UserConfigCommunity.json
    home.file.".BurpSuite/UserConfigCommunity.json" = {
      source = ./burpsuite/UserConfigCommunity.json;
      recursive = false;
      force = true;
    };
}
