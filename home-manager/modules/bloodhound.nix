{ config, lib, pkgs, ... }:

let
  configJsonPath = "${config.xdg.configHome}/bloodhound/config.json";
in
{
  xdg.configFile."bloodhound/config.json" = {
    source = ./bloodhound/config.json;
    recursive = false;
  };

  home.activation.preActivation = ''
    # Ensure the backup file is removed
    if [ -f ${configJsonPath} ]; then
      rm -f ${configJsonPath}
    fi
  '';

  home.activation.postActivate = ''
    # Ensure the existing config file is deleted
    if [ -f ${configJsonPath} ]; then
      rm -f ${configJsonPath}
    fi

    cp ${config.home.homeDirectory}/config.json ${configJsonPath}
    chmod u+w ${configJsonPath}
    rm -f ${config.home.homeDirectory}/config.json
  '';
}
