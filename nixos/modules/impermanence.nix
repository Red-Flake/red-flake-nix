{ 
  config,
  lib,
  pkgs,
  modulesPath,
  ... 
}: 
let
  cfg = config.custom.persist;
in
{
    options.custom = with lib; {
      persist = {
        root = {
          directories = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Directories to persist in root filesystem";
          };
          files = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Files to persist in root filesystem";
          };
          cache = {
            directories = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Directories to persist, but not to snapshot";
            };
            files = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Files to persist, but not to snapshot";
            };
          };
        };
        home = {
          directories = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Directories to persist in home directory";
          };
          files = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Files to persist in home directory";
          };
        };
      };
    };

    config = {

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
               "/var/lib/neo4j" # persist neo4j data
               "/var/lib/postgres" # persist postgres data
               "/var/lib/flatpak" # persist flatpak data
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
    
    };

    # setup persistence for NetworkManager, Docker, LXC
    environment.etc."NetworkManager/system-connections".source = "/persist/etc/NetworkManager/system-connections";
    systemd.tmpfiles.rules = [
      "L /var/lib/NetworkManager/secret_key - - - - /persist/var/lib/NetworkManager/secret_key"
      "L /var/lib/NetworkManager/seen-bssids - - - - /persist/var/lib/NetworkManager/seen-bssids"
      "L /var/lib/NetworkManager/timestamps - - - - /persist/var/lib/NetworkManager/timestamps"
      "L /var/lib/lxd - - - - /persist/var/lib/lxd"
      "L /var/lib/docker - - - - /persist/var/lib/docker"
    ];

}
