{
  pkgs,
  lib,
  config,
  ...
}:
{
  # Access the configured hostname and define an activation script to create `/etc/hosts`.
  system.activationScripts.initHosts = lib.mkAfter ''
        if [ ! -f /etc/hosts ]; then
          cat <<EOF > /etc/hosts
    127.0.0.1 localhost
    ::1       localhost
    127.0.0.2 ${config.networking.hostName}
    ::1       ${config.networking.hostName}
    EOF
        fi
  '';
}
