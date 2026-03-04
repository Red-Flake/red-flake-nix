{ lib
, ...
}:
{

  options.custom = {

    hostType = lib.mkOption {
      type = lib.types.enum [
        "security"
        "desktop"
        "server"
      ];
      default = "security";
      description = "Host profile type (used for conditional defaults).";
    };

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

    # Display settings
    display = {
      resolution = lib.mkOption {
        type = lib.types.str;
        default = "1080p";
        description = "Set display resolution. Options: 1080p, 1440p, 1600p, 2160p";
      };
    };

    # bootloader settings
    # Dark Matter GRUB Theme only supports 1080p and 1440p resolutions
    bootloader = {
      resolution = lib.mkOption {
        type = lib.types.str;
        default = "1080p";
        description = "Set display resolution. Options: 1080p, 1440p";
      };
    };

    # Storage optimizations
    storage = {
      hasNVMe = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether the host has NVMe storage (enables NVMe-specific udev optimizations).";
      };
    };

  };

}
