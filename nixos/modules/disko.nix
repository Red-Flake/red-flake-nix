{ lib, config, ... }: { 
  options = {
    disko.rootDisk = lib.mkOption {
      type = lib.types.str;
      default = "sda";
      description = "The device to use for the disk";
    };
  };
  config = {
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          # When using disko-install, we will overwrite this value from the commandline
          device = "/dev/${config.disko.rootDisk}";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "512M";  # Adjusted size to fit typical EFI needs
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
              zfs = {
                size = "100%";  # Allocate remaining space to ZFS
                content = {
                  type = "zfs";
                  pool = "zroot";
                };
              };
            };
          };
        };
      };
      zpool = {
        zroot = {
          type = "zpool";
          rootFsOptions = {
            compression = "lz4";
            xattr = "sa";
            atime = "off";
            acltype = "posixacl";
            "com.sun:auto-snapshot" = "false";
          };
          options.ashift = "12";
          datasets = {
            "docker".type = "zfs_fs";
            "root".type = "zfs_fs";
            "root/nixos" = {
              type = "zfs_fs";
              mountpoint = "/";
              options."com.sun:auto-snapshot" = "true";
            };
            "root/tmp" = {
              type = "zfs_fs";
              mountpoint = "/tmp";
            };
          };
        };
      };
    };
  };
}
