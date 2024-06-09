{ config, lib, pkgs, ... }:

{
  xdg.configFile."bloodhound/config.json" = {
    source = ./bloodhound/config.json;
    recursive = true;
    onChange = ''
      cp ${config.xdg.configHome}/bloodhound/config.json /tmp/
      rm -f ${config.xdg.configHome}/bloodhound/config.json
      cp /tmp/config.json ${config.xdg.configHome}/bloodhound/config.json
      chmod u+w ${config.xdg.configHome}/bloodhound/config.json
    '';
  };
}
