{ 
  config,
  lib,
  pkgs,
  modulesPath,
  ... 
}:
let
  cfg = config.custom.zfs;
  isVm = lib.elem "virtio_blk" config.boot.initrd.availableKernelModules;
  redflake-plymouth-src = pkgs.fetchFromGitHub {
      owner = "Red-Flake";
      repo = "redflake-plymouth";
      rev = "master";
      sha256 = "2lrdGR1WfS24lCwV6p15Eag9JZtbwmm6nhzlZ5b2esc=";
  };
  redflake-plymouth = pkgs.callPackage redflake-plymouth-src {};
in
# NOTE: zfs datasets are created via install.sh
{
  boot = {

      # Set kernel parameters
      kernelParams = [
        "quiet"
        "splash"
        "nohibernate"
        "elevator=none"
        "i915.enable_fbc=1"
        "i915.fastboot=1"
        "fsck.mode=skip"
        "loglevel=0"
        "rd.systemd.show_status=false"
        "nowatchdog"
        "kernel.nmi_watchdog=0"
        "nomce"
        "mitigations=off"
        "libahci.ignore_sss=1"
        "modprobe.blacklist=iTCO_wdt"
        "modprobe.blacklist=sp5100_tco"
        "processor.ignore_ppc=1"
        "sysrq_always_enabled=1"
        "split_lock_detect=off"
        "consoleblank=0"
        "audit=0"
        "net.ifnames=0"
        "biosdevname=0"
        "SYSTEMD_CGROUP_ENABLE_LEGACY_FORCE=1"
        "systemd.unified_cgroup_hierarchy=0"
      ];

      # Switch to Xanmod kernel
      kernelPackages = pkgs.linuxPackages_xanmod_latest;

      # Initramfs settings
      initrd = {

          # enable stage-1 bootloader
          systemd.enable = true;

          # Set kernel modules
          availableKernelModules = [ 
              "zfs"
              "xhci_pci"
              "thunderbolt"
              "nvme"
              "usb_storage"
              "usbhid"
              "sd_mod"
              "ahci"
          ];

          # Enable ZFS filesystem support
          supportedFilesystems = [ "zfs" ];

      };

      # Set extra kernel module options
      extraModprobeConfig = "options kvm_intel nested=1";

      # Enable ZFS filesystem support
      supportedFilesystems = [ "zfs" ];

      # ZFS settings
      zfs = {
          devNodes =
              if isVm then
                  "/dev/disk/by-partuuid"
              # use by-id for intel mobo when not in a vm
              else if config.hardware.cpu.intel.updateMicrocode then
                  "/dev/disk/by-id"
              else
                "/dev/disk/by-partuuid";

          package = pkgs.zfs_unstable;
          requestEncryptionCredentials = cfg.encryption;
      };

      # Clear /tmp on boot & use tmpfs
      tmp = {
          cleanOnBoot = true;
          useTmpfs = true;
      };

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
                resolution = "1080p";
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
