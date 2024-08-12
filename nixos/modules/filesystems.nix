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
      device =
        if !isVm then
          "/dev/disk/by-partlabel/SWAP"
        else
          "/dev/disk/by-label/SWAP";
    }
  ];

  fileSystems = {
      "/" = {
        device = "zroot/root";
        fsType = "zfs";
        neededForBoot = true;
      };

      "/boot" = {
        device =
          if !isVm then
            "/dev/disk/by-partlabel/NIXBOOT"
          else
            "/dev/disk/by-label/NIXBOOT";
        fsType = "vfat";
      };

      "/nix" = {
        device = "zroot/nix";
        fsType = "zfs";
      };

      "/tmp" = {
        device = "zroot/tmp";
        fsType = "zfs";
      };

      "/persist" = {
        device = "zroot/persist";
        fsType = "zfs";
        neededForBoot = true;
      };

      "/persist/cache" = {
        device = "zroot/cache";
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
