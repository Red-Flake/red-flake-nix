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

  services = {
    # Workaround for Intel throttling issues in Linux.
    throttled.enable = true;
  };

}
