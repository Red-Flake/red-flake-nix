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
      enableRedistributableFirmware = true;

      # enable all firmware regardless of license
      enableAllFirmware = true;

      cpu = {
        intel = {
          # update the CPU microcode for Intel processors
          updateMicrocode = true;
        };
      };

    };

    services = {
      # Workaround for Intel throttling issues in Linux.
      throttled.enable = true;
    };

}
