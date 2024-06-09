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
  ];

  # Switch to latest linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Set kernel modules
  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  
  # Set initramfs kernel modules
  # Enable AMD video driver + Intel video driver via early KMS
  boot.initrd.kernelModules = [
    "amdgpu"
    "i915"
  ];

  boot.kernelModules = [ "kvm-intel" "acpi_call" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.acpi_call ];

  # Clear /tmp on boot
  boot.tmp.cleanOnBoot = true;

  # Bootloader settings
  boot.loader = {
    systemd-boot.enable = false;

    timeout = 3;

    # EFI settings
    efi = {
      canTouchEfiVariables = false;
      efiSysMountPoint = "/boot";
    };

    # Enable Grub Bootloader
    grub = {
      enable = true;

      efiSupport = true;
      efiInstallAsRemovable = true; # Otherwise /boot/EFI/BOOT/BOOTX64.EFI isn't generated
      devices = [ "nodev" ];
      useOSProber = true;

    };

  };
}
