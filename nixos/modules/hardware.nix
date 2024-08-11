{ 
  config,
  lib,
  pkgs,
  modulesPath,
  ... 
}: {

  options.custom = {

    hardware = {
      enableRedistributableFirmware = lib.mkEnableOption "Enable redistributable firmware";
      cpu = {
        amd = {
          updateMicrocode = lib.mkEnableOption "Enable CPU microcode updates for AMD CPUs";
        };
        intel = {
          updateMicrocode = lib.mkEnableOption "Enable CPU microcode updates for Intel CPUs";
        };
      };
    };

    # ZFS settings
    zfs = {
      encryption = lib.mkEnableOption "zfs encryption" // {
        default = true;
      };
    };
    
  };
  
}
