{ 
  config,
  lib,
  pkgs,
  modulesPath,
  ... 
}: {

  options.custom = {

    # ZFS settings
    zfs = {
      encryption = lib.mkEnableOption "zfs encryption" // {
        default = true;
      };
    };

    # Intel OpenCL legacy runtime settings
    IntelComputeRuntimeLegacy = {
      enable = lib.mkEnableOption "intel compute runtime legacy" // {
        default = false;
      };
    };

  };
  
}
