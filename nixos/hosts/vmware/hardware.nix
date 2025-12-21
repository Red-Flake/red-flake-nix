{ lib, ... }:
{

  custom = {
    # enable ZFS encryption
    zfs.encryption = true;

    # set display resolution to 1080p
    display.resolution = "1080p";

    # set bootloader resolution to 1080p or 1440p (Dark Matter GRUB Theme only supports these two resolutions)
    bootloader.resolution = "1080p";
  };

  hardware = {
    # enable firmware with a license allowing redistribution
    enableRedistributableFirmware = lib.mkForce true;

    # enable all firmware regardless of license
    enableAllFirmware = lib.mkForce true;
  };

  # Enable vmware video driver for better performance
  services.xserver.videoDrivers = [ "vmware" ];

  # Enable VMWare guest tools
  virtualisation.vmware.guest.enable = true;

}
