{ config, lib, pkgs, modulesPath, ... }:

{
  # Set kernel parameters
  boot.kernelParams = [
    "quiet"
    "splash"
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
    "systemd.unified_cgroup_hierarchy=0"
    "systemd_cgroup_enable_legacy_force=1"
  ];

  # Switch to CachyOS LTO optimized kernel
  #boot.kernelPackages = pkgs.linuxPackages_cachyos-lto;
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  # Set kernel modules
  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "usbhid" "sd_mod" "ahci" ];
  
  # Set initramfs kernel modules
  # Enable AMD video driver + Intel video driver via early KMS
  boot.initrd.kernelModules = [
    "amdgpu"
    "i915"
  ];

  # Set extra kernel module options
  boot.extraModprobeConfig = "options kvm_intel nested=1";

  # Clear /tmp on boot & use tmpfs
  boot.tmp = {
    cleanOnBoot = true;
    useTmpfs = true;
  };

  # Enable Plymouth
  boot.plymouth.enable = true;
  
  # Enable nixos-boot
  # https://github.com/Melkor333/nixos-boot
  nixos-boot = {
    enable  = true;

    # Different colors
    bgColor.red   = 0; # 0 - 255
    bgColor.green = 0; # 0 - 255
    bgColor.blue  = 0; # 0 - 255

    # If you want to make sure the theme is seen when your computer starts too fast
    # duration = 3; # in seconds
  };

  # Bootloader settings
  boot.loader = {
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

      efiSupport = true;
      device = "nodev";
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
