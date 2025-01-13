{ 
  config,
  lib,
  pkgs,
  inputs,
  ... 
}: {

  custom = {
    # disable ZFS encryption
    zfs.encryption = false;
  };

  hardware = {
    # enable firmware with a license allowing redistribution
    enableRedistributableFirmware = lib.mkForce true;

    # enable all firmware regardless of license
    enableAllFirmware = lib.mkForce true;
  };

}
