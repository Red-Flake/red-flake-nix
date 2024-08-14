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
    
  };
  
}
