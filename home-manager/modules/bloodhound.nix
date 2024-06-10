{ config, lib, pkgs, ... }:

let
  configJsonPath = "${config.xdg.configHome}/bloodhound/config.json";
in
{
  xdg.configFile."bloodhound/config.json" = {
    source = ./bloodhound/config.json;
    recursive = true;
    onChange = ''
      cp ${config.xdg.configHome}/bloodhound/config.json ${config.home.homeDirectory}
      rm -f ${config.xdg.configHome}/bloodhound/config.json
      cp ${config.home.homeDirectory}/config.json ${config.xdg.configHome}/bloodhound/config.json
      chmod u+w ${config.xdg.configHome}/bloodhound/config.json
      rm -f ${config.home.homeDirectory}/config.json
    '';
  };
}
