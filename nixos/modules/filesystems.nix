{ config, lib, pkgs, ... }:

{
  swapDevices = [
    {
      device = "/dev/disk/by-label/SWAP";
    }
  ];

  fileSystems = {
      "/" = {
        device = "zroot/root";
        fsType = "zfs";
        options = [ "zfsutil" ];
        neededForBoot = true;
      };

      "/boot" = {
        device = "/dev/disk/by-label/NIXBOOT";
        fsType = "vfat";
      };

      "/nix" = {
        device = "zroot/nix";
        fsType = "zfs";
        options = [ "zfsutil" ];
      };

      "/tmp" = {
        device = "zroot/tmp";
        fsType = "zfs";
        options = [ "zfsutil" ];
      };

      "/persist/cache" = {
        device = "zroot/cache";
        fsType = "zfs";
        options = [ "zfsutil" ];
        neededForBoot = true;
      };

      "/persist" = {
        device = "zroot/persist";
        fsType = "zfs";
        options = [ "zfsutil" ];
        neededForBoot = true;
      };
  };    

  # https://github.com/openzfs/zfs/issues/10891
  systemd.services.systemd-udev-settle.enable = false;

  # https://github.com/NixOS/nixpkgs/issues/257505
  #custom.shell.packages.remount-persist = ''
  #  sudo mount -t zfs zroot/persist -o remount
  #'';

}
