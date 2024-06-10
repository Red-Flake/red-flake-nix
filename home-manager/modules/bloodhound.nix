{ config, lib, pkgs, ... }:

let
  configJsonPath = "${config.xdg.configHome}/bloodhound/config.json";
  sourceConfigJsonPath = "${./bloodhound/config.json}";
in
{
  home.activation.preActivation = ''
    # Ensure the existing config file is removed before activation
    if [ -f ${configJsonPath} ]; then
      rm -f ${configJsonPath}
    fi

    # Copy the new config file
    cp ${sourceConfigJsonPath} ${configJsonPath}
  '';

  home.activation.postActivate = ''
    # Ensure the config file has the correct permissions
    chmod u+w ${configJsonPath}
  '';
}
