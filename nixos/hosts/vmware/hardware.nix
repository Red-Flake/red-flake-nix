{ 
  config,
  lib,
  pkgs,
  inputs,
  ... 
}: {

  custom = {
    # enable ZFS encryption
    zfs.encryption = true;
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
