{ config, lib, pkgs, ... }:

{
  xdg.configFile."bloodhound/config.json" = {
    source = ./bloodhound/config.json;
    recursive = true;
    onChange = ''
      cp ${config.xdg.configHome}/bloodhound/config.json ${home.homeDirectory}
      rm -f ${config.xdg.configHome}/bloodhound/config.json
      cp ${home.homeDirectory}/config.json ${config.xdg.configHome}/bloodhound/config.json
      chmod u+w ${config.xdg.configHome}/bloodhound/config.json
      rm -f ${home.homeDirectory}/config.json
    '';
  };
}
