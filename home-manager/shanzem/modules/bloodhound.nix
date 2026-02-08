{ config
, lib
, ...
}:

let
  bloodhoundPath = "${config.xdg.configHome}/bloodhound";
  configJsonPath = "${config.xdg.configHome}/bloodhound/config.json";
  sourceConfigJsonPath = "${./bloodhound/config.json}";
in
{
  home.activation = {
    bloodhound = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Check if bloodhound folder exists
      if [ ! -d "${bloodhoundPath}" ]; then
        # If not, create bloodhound folderbloodhound
        mkdir -p "${bloodhoundPath}"
      fi

      # Ensure the existing config file is removed before activation
      if [ -f "${configJsonPath}" ]; then
        rm -f "${configJsonPath}"
      fi

      # Copy the new config file
      cp "${sourceConfigJsonPath}" "${configJsonPath}"

      # Ensure the config file has the correct permissions
      if [ -f "${configJsonPath}" ]; then
        chmod u+w "${configJsonPath}"
      else
        echo "Config file not found: ${configJsonPath}"
      fi
    '';
  };

  xdg.desktopEntries.bloodhound = {
    name = "BloodHound";
    genericName = "Six Degrees of Domain Admin";
    exec = ''
      env XCURSOR_SIZE=36 BloodHound --no-sandbox --ozone-platform=wayland --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --disable-features=WaylandWpColorManagerV1 %U
    '';
    icon = "${config.home.homeDirectory}/.local/share/icons/red-flake/bloodhound.svg";
    terminal = false;
    type = "Application";
    categories = [
      "X-Post-Exploitation"
    ];
    startupNotify = true;
    settings = {
      StartupWMClass = "BloodHound";
    };
  };
}
