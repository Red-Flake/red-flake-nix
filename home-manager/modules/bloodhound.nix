{ config, lib, pkgs, ... }:

let
  configJsonPath = "${config.xdg.configHome}/bloodhound/config.json";
  backupConfigJsonPath = "${config.xdg.configHome}/bloodhound/config.json.hm-backup";
in
{
  xdg.configFile."bloodhound/config.json" = {
    source = ./bloodhound/config.json;
    recursive = false;
    onChange = ''
      if [ -f ${backupConfigJsonPath} ]; then
        rm -f ${backupConfigJsonPath}
      fi

      cp ${configJsonPath} ${config.home.homeDirectory}
      rm -f ${configJsonPath}
      cp ${config.home.homeDirectory}/config.json ${configJsonPath}
      chmod u+w ${configJsonPath}
      rm -f ${config.home.homeDirectory}/config.json
    '';
  };

  home.activation.postActivate = ''
    if [ -f ${backupConfigJsonPath} ]; then
      rm -f ${backupConfigJsonPath}
    fi

    cp ${configJsonPath} ${config.home.homeDirectory}
    rm -f ${configJsonPath}
    cp ${config.home.homeDirectory}/config.json ${configJsonPath}
    chmod u+w ${configJsonPath}
    rm -f ${config.home.homeDirectory}/config.json
  '';
}
