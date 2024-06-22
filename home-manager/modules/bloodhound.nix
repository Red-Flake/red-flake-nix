{ config, lib, pkgs, ... }:

let
  bloodhoundPath = "${config.xdg.configHome}/bloodhound";
  configJsonPath = "${config.xdg.configHome}/bloodhound/config.json";
  sourceConfigJsonPath = "${./bloodhound/config.json}";
  desktopFilePath = "${config.xdg.dataHome}/applications";
  destinationDesktopFilePath = "${config.xdg.dataHome}/applications/bloodhound.desktop";
  sourceDesktopFilePath = "${./bloodhound/bloodhound.desktop}";
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
    
    # Ensure the applications directory exists
    if [ ! -d "$(dirname "${desktopFilePath}")" ]; then
      mkdir -p "$(dirname "${desktopFilePath}")"
    fi

    # Copy the .desktop file
    cp "${sourceDesktopFilePath}" "${destinationDesktopFilePath}"
  '';

  home.activation.postActivate = ''
    # Ensure the config file has the correct permissions
    if [ -f "${configJsonPath}" ]; then
      chmod u+w "${configJsonPath}"
    else
      echo "Config file not found: ${configJsonPath}"
    fi

    # Ensure the .desktop file has the correct permissions
    if [ -f "${destinationDesktopFilePath}" ]; then
      chmod u+rx "${destinationDesktopFilePath}"
    else
      echo "Desktop file not found: ${destinationDesktopFilePath}"
    fi
  '';
}
