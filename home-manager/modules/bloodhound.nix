{ config, lib, pkgs, ... }:

let
  configJsonPath = "${config.xdg.configHome}/bloodhound/config.json";
in
{
  xdg.configFile."bloodhound/config.json" = {
    source = ./bloodhound/config.json;
    recursive = false;
    # We can still keep the onChange if needed
    onChange = ''
      cp ${configJsonPath} ${config.home.homeDirectory}
      rm -f ${configJsonPath}
      cp ${config.home.homeDirectory}/config.json ${configJsonPath}
      chmod u+w ${configJsonPath}
      rm -f ${config.home.homeDirectory}/config.json
    '';
  };

  # Ensure commands are always run during activation
  home.activation.postActivate = ''
    cp ${configJsonPath} ${config.home.homeDirectory}
    rm -f ${configJsonPath}
    cp ${config.home.homeDirectory}/config.json ${configJsonPath}
    chmod u+w ${configJsonPath}
    rm -f ${config.home.homeDirectory}/config.json
  '';

}
