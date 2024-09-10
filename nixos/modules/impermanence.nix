{ 
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
          ]
      };

      "/persist/cache" = {
          hideMounts = true;
          inherit (cfg.root.cache) directories files;
      };
   };
}
