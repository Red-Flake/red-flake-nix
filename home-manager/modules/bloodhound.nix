{ config, lib, pkgs, ... }:

let
  bloodhoundPath = "${config.xdg.configHome}/bloodhound";
  configJsonPath = "${config.xdg.configHome}/bloodhound/config.json";
  sourceConfigJsonPath = "${./bloodhound/config.json}";
in
{
  home.activation.preActivation = ''
    # Check if bloodhound folder exists
    if [ ! -d "${bloodhoundPath}" ]; then
      # If not, create bloodhound folder
      mkdir -p "${bloodhoundPath}"
    fi

    # Ensure the existing config file is removed before activation
    if [ -f "${configJsonPath}" ]; then
      rm -f "${configJsonPath}"
    fi
    
    # Copy the new config file
    cp "${sourceConfigJsonPath}" "${configJsonPath}"
  '';

  home.activation.postActivate = ''
    # Ensure the config file has the correct permissions
    if [ -f "${configJsonPath}" ]; then
      chmod u+w "${configJsonPath}"
    else
      echo "Config file not found: ${configJsonPath}"
    fi
  '';

  xdg.desktopEntries.bloodhound = {
    name = "BloodHound";
    genericName = "BloodHound";
    exec = "BloodHound";
    icon = "kali-bloodhound";
  };
}
