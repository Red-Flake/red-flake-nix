{ config
, lib
, pkgs
, ...
}:
{

  custom = {
    # disable ZFS encryption
    zfs.encryption = lib.mkForce false;

    kernel.cachyos.mArch = "GENERIC_V3";

    # set display resolution to 1080p
    display.resolution = "1080p";

    # set bootloader resolution to 1080p or 1440p (Dark Matter GRUB Theme only supports these two resolutions)
    bootloader.resolution = "1080p";
  };

  # Increase the number of parallel build jobs for Nix to 24
  nix.settings.max-jobs = lib.mkForce 8;

  boot = {
    initrd.availableKernelModules = [
      "zfs"
      "ahci"
      "xhci_pci"
      "sr_mod"
      "nvme"
      "usb_storage"
      "usbhid"
      "thunderbolt"
    ];
    initrd.kernelModules = [ "amdgpu" ];
    kernelModules = [
      "kvm-amd"
      "rtw88_usb"
      "rtw88_8822bu"
    ];
    extraModulePackages = with config.boot.kernelPackages; [
      rtw88
    ];
    extraModprobeConfig = ''
      options rtw88_usb switch_usb_mode=N
      options rtw88_core disable_lps_deep=y
      options rtw88_pci disable_aspm=y disable_msi=y
      options rtw_core disable_lps_deep=y
      options rtw_pci disable_msi=y disable_aspm=y
    '';

    kernelParams = [
      "amd_pstate=active"
      "acpi_enforce_resources=lax"
      "preempt=full"
      "transparent_hugepage=madvise"
      "split_lock_detect=off"
      "pcie_aspm.policy=performance"
      "mitigations=off"
    ];
  };

  hardware = {
    # enable firmware with a license allowing redistribution
    enableRedistributableFirmware = lib.mkForce true;

    # enable all firmware regardless of license
    enableAllFirmware = lib.mkForce true;

    # enable CPU microcode updates
    cpu.amd.updateMicrocode = true;

    amdgpu.opencl.enable = true; # Proprietary AMD OpenCL support
    amdgpu.initrd.enable = true; # Enable Initrd support

    graphics = {
      enable = true;
      enable32Bit = true;

      # Optional: extra Vulkan ICD and Mesa Vulkan layers, useful for some apps and games
      extraPackages = with pkgs; [
        vulkan-tools # For vulkaninfo and debugging Vulkan apps
      ];
    };
  };

  services.fstrim.enable = true;

  # Recommended to explicitly declare video driver for Xorg and fallback support
  services.xserver.videoDrivers = [ "amdgpu" ];

  environment.variables.AMD_VULKAN_ICD = "RADV";

  environment.systemPackages = with pkgs; [
    clinfo
    vulkan-tools
    mesa-demos
    radeontop # AMD GPU utilization monitor
    lm_sensors # For temperature sensors
    pciutils
  ];

  # Allow firmware Updates
  services.fwupd.enable = true;
}
