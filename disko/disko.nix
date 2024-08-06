{
  device,
  user,
}: {

  rg.resetRootFsPoolName = "zroot";

  disko.devices = {
    disk.main = {
      type = "disk";
      device = device;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          zrootpool = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "zroot";
            };
          };
        };
      };
    };
    zpool.zroot = {
        type = "zpool";
        options = {
          ashift = "12";
        };
        # Create a snapshot of the root filesystem as soon as it's created.
        postCreateHook = "zfs snapshot zroot@blank";
        rootFsOptions = {
          # Enable additional access control features as they're intended to be used
          # in ZFS.
          acltype = "posixacl";
          xattr = "sa";
          # Enable compression by default.
          compression = "zstd";
          # Don't allow the pool itself to be mounted
          canmount = "off";
          atime = "off";
          dnodesize = "auto";
          normalization = "formD";
          mountpoint = "none";
        };
        datasets = {
          datasets = {
            "local" = {
              type = "zfs_fs";
              options = {
                sync = "disabled";
              };
            };
            "local/root" = {
              type = "zfs_fs";
              mountpoint = "/";
              postCreateHook = "zfs snapshot zroot/local/root@blank";
              # options = {
              #   sync = "disabled";
              # };
            };
            "local/user" = {
              type = "zfs_fs";
              mountpoint = "/home/${user}";
              postCreateHook = "zfs snapshot zroot/local/user@blank";
              # options = {
              #   sync = "disabled";
              # };
            };
            "local/docker" = {
              type = "zfs_fs";
              mountpoint = "/var/lib/docker";
              # options = {
              #   sync = "disabled";
              # };
            };
            "local/cache" = {
              type = "zfs_fs";
              mountpoint = "/var/cache";
              # options = {
              #   sync = "disabled";
              # };
            };
            "local/nix" = {
              type = "zfs_fs";
              mountpoint = "/nix";
              # options = {
              #   sync = "disabled";
              # };

            };
            "local/reserved" = {
              type = "zfs_fs";
              options = {
                mountpoint = "none";
                refreservation = "2G";
              };
            };
            "local/state" = {
              type = "zfs_fs";
              mountpoint = "/state";
            };
            "safe/persist" = {
              type = "zfs_fs";
              mountpoint = "/pst";
            };
          };
        };
      };
  };
  
  fileSystems."/pst".neededForBoot = true;
  fileSystems."/state".neededForBoot = true;
}