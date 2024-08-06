{ config, lib, pkgs, modulesPath, ... }:

{
  disko.devices = {
    
    disk = {
      main = {
        # When using disko-install, we will overwrite this value from the commandline
        device = "/dev/disk/by-id/some-disk-id";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            MBR = {
              type = "EF02"; # for grub MBR
              size = "1M";
            };
            efi = {
              type = "EF00";
              size = "1024M";
              name = "efi";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            crypt = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypt";
                extraOpenArgs = [ "--allow-discards" ];
                #passwordFile = "/tmp/secret.key";
                content = {
                  type = "zfs";
                  pool = "zfspool";
                };
              };
            };
          };
        };
      };
    };

    zpool = {
      zfspool = {
        type = "zpool";
        rootFsOptions = {
          canmount = "off";
        };
        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
            postCreateHook = "zfs snapshot zfspool/root@blank";
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "legacy";
          };
          persist = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/persist";
          };
          home = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/home";
            postCreateHook = "zfs snapshot zfspool/home@blank";
          };
        };
      };
    };

  };
}
