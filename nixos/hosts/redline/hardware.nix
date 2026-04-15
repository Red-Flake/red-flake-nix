{ lib, pkgs, ... }:
{

  custom = {
    # disable ZFS encryption
    zfs.encryption = lib.mkForce false;

    # set display resolution to 1080p
    display.resolution = "1440p";
  };

  # Increase the number of parallel build jobs for Nix to 24
  nix.settings.max-jobs = lib.mkForce 12;

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
      "kvm-intel"
      "intel_rapl"
    ];
    extraModulePackages = [ ];

    kernelParams = [
      # Display output configuration
      "video=DP-3:2560x1440@165"
      "video=HDMI-A-1:1920x1080@144"

      # Boot / quiet
      "quiet"
      "splash"

      # Security mitigations off for performance
      "mitigations=off"

      # AHCI: skip staggered spin-up for faster boot
      "libahci.ignore_sss=1"

      # Enable SysRq key for debugging/recovery
      "sysrq_always_enabled=1"

      # Disable split lock detection
      "split_lock_detect=off"

      # Disable audit subsystem
      "audit=0"

      # Classic network interface naming (eth0, wlan0)
      "net.ifnames=0"
      "biosdevname=0"
    ];
  };

  hardware = {
    # enable CPU microcode updates
    cpu.intel.updateMicrocode = true;

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

}
