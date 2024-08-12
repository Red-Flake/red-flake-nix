{ 
  config,
  lib,
  pkgs,
  ... 
}:
let
  cfg = config.custom.zfs;
  isVm = lib.elem "virtio_blk" config.boot.initrd.availableKernelModules;
in
{
  
  swapDevices = [
    {
      device = "/dev/disk/by-label/SWAP";
    }
  ];

  fileSystems = {
      "/" = {
        device = "zroot/root/nixos";
        fsType = "zfs";
        neededForBoot = true;
      };

      "/boot" = {
        device = "/dev/disk/by-label/NIXBOOT";
        fsType = "vfat";
      };

      "/home" = {
        device = "zroot/root/home";
        fsType = "zfs";
      };

      "/nix" = {
        device = "zroot/root/nix";
        fsType = "zfs";
      };

      "/tmp" = {
        device = "zroot/root/tmp";
        fsType = "zfs";
      };

      "/persist" = {
        device = "zroot/persist";
        fsType = "zfs";
        neededForBoot = true;
      };

      "/persist/cache" = {
        device = "zroot/root/cache";
        fsType = "zfs";
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
