{ config
, lib
, pkgs
, ...
}:

let
  kwalletrcPath = "${config.xdg.configHome}/kwalletrc";
  sourceKwalletrcPath = "${./kwallet/kwalletrc}";
in
{
  home.activation = {
    kwallet = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Remove the config file only if it is a symlink
      if [ -L "${kwalletrcPath}" ]; then
        rm -f "${kwalletrcPath}"
      fi

      # Copy the new config file only if it doesn't already exist
      if [ ! -e "${kwalletrcPath}" ]; then
        cp "${sourceKwalletrcPath}" "${kwalletrcPath}"
      fi

      # Ensure the config file has the correct permissions
      if [ -f "${kwalletrcPath}" ]; then
        chmod u+w "${kwalletrcPath}"
      else
        echo "Config file not found: ${kwalletrcPath}"
      fi
    '';
  };
}
