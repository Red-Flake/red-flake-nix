{ config, lib, pkgs, ... }:

{
  fileSystems."/" = {
    device = "zroot/root";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/boot" = {
    device = "LABEL=NIXBOOT";
    fsType = "vfat";
  };

  fileSystems."/nix" = {
    device = "zroot/nix";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/tmp" = {
    device = "zroot/tmp";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/cache" = {
    device = "zroot/cache";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/persist" = {
    device = "zroot/persist";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  swapDevices = [
    {
      device = "LABEL=SWAP";
    }
  ];
}
