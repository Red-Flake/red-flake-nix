{ 
  config,
  lib,
  pkgs,
  modulesPath,
  ... 
}: {
  # setup persistence
  environment.persistence = {

     "/persist" = {
         hideMounts = true;
         files = [ 
           "/etc/machine-id" # for persistent machine-id
         ] ++ [
           # YOUR FILES
         ];
         directories = [
           "/var/log" # systemd journal is stored in /var/log/journal
           "/var/lib/nixos" # for persisting user uids and gids
         ] ++ [
           # YOUR DIRECTORIES
           "/etc/NetworkManager/system-connections"
           "/var/lib/NetworkManager"
           "/var/lib/systemd/coredump"
           "/var/lib/bluetooth"
           "/var/lib/upower"
           "/var/lib/neo4j" # persist neo4j data
           "/var/lib/postgres" # persist postgres data
           "/var/lib/flatpak" # persist flatpak data
           "/etc/ssl/certs/" # persist ssl certs
         ];
     };

    "/persist/cache" = {
        hideMounts = true;
        directories = [
          "/var/lib/docker" # persist docker data
          "/var/lib/containers/storage" # persist container storage
          "/var/lib/libvirt" # persist libvirt data
          "/var/lib/lxd" # persist LXC data
        ];
    };

  };

}
