{ config
, isKVM
, pkgs
, ...
}:
let
  cfg = config.custom;
  redflake-plymouth-src = builtins.fetchTarball {
    url = "https://github.com/Red-Flake/redflake-plymouth/archive/cad99c2de44912689d7d7deed3eb0543fcb6a300.tar.gz";
    sha256 = "sha256-1Ffm32nVOgPw8LeJVwTZ3Ef2y9zIZAkud5oLr9znNj4=";
  };
  redflake-plymouth = pkgs.callPackage (redflake-plymouth-src + "/default.nix") { };
in
# NOTE: zfs datasets are created via install.sh
{
  boot = {

    # Set kernel parameters
    kernelParams = [
      "quiet"
      "splash"
      "loglevel=0"
      "rd.systemd.show_status=false"
      "nowatchdog"
      "nmi_watchdog=0"
      "mitigations=off"
      "libahci.ignore_sss=1"
      "modprobe.blacklist=iTCO_wdt"
      "modprobe.blacklist=sp5100_tco"
      "sysrq_always_enabled=1"
      "split_lock_detect=off"
      "audit=0"
      "net.ifnames=0"
      "biosdevname=0"
    ];

    # Switch to latest Linux CachyOS Kernel (BORE) compiled with Clang+ThinLTO
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;

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

      # Use ZFS 2.4.0 userspace package (Linux 6.18 requires ZFS 2.4.0+)
      # boot.zfs.package expects the userspace package, not the kernel module
      package = pkgs.zfs_unstable;
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

    # Bootloader settings
    loader = {
      systemd-boot.enable = false;

      timeout = 3;

      # EFI settings
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };

      # Enable Grub Bootloader
      grub = {
        enable = true;

        copyKernels = true;

        efiSupport = true;
        devices = [ "nodev" ];
        useOSProber = true;
        fontSize = 24;

        # Use Dark Matter GRUB Theme
        darkmatter-theme = {
          enable = true;
          style = "nixos";
          icon = "color";
          inherit (cfg.bootloader) resolution;
        };
      };
    };

  };

  # fix bug that bootloader entry name cannot be set via boot.loader.grub.configurationName
  # see: https://github.com/NixOS/nixpkgs/issues/15416
  system.activationScripts.update-grub-menu = {
    text = ''
      echo "Updating GRUB menu entry name..."

      GRUB_CFG="/boot/grub/grub.cfg"
      BACKUP_GRUB_CFG="/boot/grub/grub.cfg.bak"
      SEARCH_STR="\"NixOS"
      REPLACE_STR="\"Red Flake"

      if [ -f "$GRUB_CFG" ]; then
          cp "$GRUB_CFG" "$BACKUP_GRUB_CFG"
          ${pkgs.gnused}/bin/sed -i "s/$SEARCH_STR/$REPLACE_STR/g" "$GRUB_CFG"
      else
          echo "Error: GRUB configuration file not found."
      fi
    '';
  };

}
