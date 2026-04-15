{ config
, isKVM
, pkgs
, pkgsUnstable
, inputs
, ...
}:
let
  cfg = config.custom;
  redflake-plymouth = pkgs.callPackage (inputs.redflakePlymouth + "/default.nix") { };
in
# NOTE: zfs datasets are created via install.sh
{
  boot = {
    # Kernel parameters are now set per-host in each host's hardware.nix

    # Kernel selection is handled by `custom.kernel.*` (see `nixos/modules/kernel.nix`).

    # Initramfs settings
    initrd = {
      # enable stage-1 bootloader
      systemd.enable = true;

      # Enable ZFS filesystem support
      supportedFilesystems = [ "zfs" ];
    };

    # Enable ZFS filesystem support
    supportedFilesystems = [ "zfs" ];

    # ZFS settings
    zfs = {
      devNodes =
        if isKVM then
          "/dev/disk/by-partuuid"
        # use by-id for intel mobo when not in a vm
        else if config.hardware.cpu.intel.updateMicrocode then
          "/dev/disk/by-id"
        else
          "/dev/disk/by-path";

      # Use ZFS 2.4.1 from pkgsUnstable (supports kernels 4.18 - 6.19)
      # Must override kernel module to use the same version as userspace
      package = pkgsUnstable.zfs_2_4;

      requestEncryptionCredentials = cfg.zfs.encryption;
    };

    # Clear /tmp on boot, since it's a zfs dataset
    tmp.cleanOnBoot = true;

    # Enable Plymouth
    plymouth = {
      enable = true;
      themePackages = [ redflake-plymouth ];
      theme = "redflake-plymouth";
    };

    # Silent boot - suppress kernel messages so Plymouth can display
    consoleLogLevel = 0;
    initrd.verbose = false;

    # Bootloader settings
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 20;
        editor = false;
      };

      timeout = 2;

      # EFI settings
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };

  };

}
