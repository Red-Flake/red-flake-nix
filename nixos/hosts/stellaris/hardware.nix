{
  config,
  lib,
  pkgs,
  inputs,
  tuxedo-nixos,
  ...
}:
{

  custom = {
    # enable ZFS encryption
    zfs.encryption = true;

    # disable Intel OpenCL legacy runtime
    IntelComputeRuntimeLegacy.enable = false;

    # set display resolution to 1600p
    display.resolution = "1600p";

    # set bootloader resolution to 1080p or 1440p (Dark Matter GRUB Theme only supports these two resolutions)
    bootloader.resolution = "1440p";
  };

  boot = {
    initrd.availableKernelModules = [
      "zfs"
      "xhci_pci"
      "thunderbolt"
      "nvme"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "ahci"
      "msr"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [
      "kvm-intel"
      "msr" # /dev/cpu/CPUNUM/msr provides an interface to read and write the model-specific registers (MSRs) of an x86 CPU
      "tuxedo_keyboard"
      "tuxedo-io"
    ];
    extraModulePackages = with pkgs; [
      linuxKernel.packages.linux_xanmod_latest.tuxedo-drivers
    ];

    # TUXEDO-specific: set keyboard brightness and color at boot
    kernelParams = [
      "tuxedo_keyboard.mode=0"
      "tuxedo_keyboard.brightness=255"
      "tuxedo_keyboard.color_left=0x0000ff"
    ];

    # Set extra kernel module options
    extraModprobeConfig = ''
      options kvm_intel nested=1
      options iwlmvm power_scheme=1
      options iwlwifi power_save=0 uapsd_disable=1
    '';
  };

  hardware = {
    # enable firmware with a license allowing redistribution
    enableRedistributableFirmware = lib.mkForce true;

    # enable all firmware regardless of license
    enableAllFirmware = lib.mkForce true;

    # enable CPU microcode updates
    cpu.intel.updateMicrocode = lib.mkForce true;

    # Enable general graphics acceleration (required for hybrid setups)
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        libvdpau-va-gl # VDPAU driver with OpenGL/VAAPI backend
        vpl-gpu-rt # For Intel QSV (Quick Sync Video)
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        libvdpau-va-gl # VDPAU driver with OpenGL/VAAPI backend
        vpl-gpu-rt # For Intel QSV (Quick Sync Video)
      ];
    };

    # NVIDIA hybrid graphics setup (PRIME offload mode for battery efficiency; switch to sync if needed for performance)
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true; # Enable for laptop power saving
      powerManagement.finegrained = false;
      open = false; # Proprietary driver for RTX 50-series
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable; # Or .production if stability issues
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        # Bus IDs: Run `lspci | egrep 'VGA|3D'` post-install to confirm; these are typical for Intel + NVIDIA laptops
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:2:0:0";
      };
    };

    # TUXEDO-specific: drivers, Keyboard lighting and fan control (from nixpkgs)
    tuxedo-drivers.enable = lib.mkForce true;
    tuxedo-keyboard.enable = lib.mkForce false; # Important: disable tuxedo-keyboard to avoid conflict with tuxedo-drivers
    tuxedo-rs = {
      # Important: disable tuxedo-rs and tailor-gui to avoid conflict with tuxedo-drivers and tuxedo-control-center
      enable = lib.mkForce false;
      tailor-gui.enable = lib.mkForce false; # GUI for TUXEDO Control Center equivalent
    };
    tuxedo-control-center = {
      enable = true; # Enable original TUXEDO Control Center via tuxedo-nixos
      package = inputs.tuxedo-nixos.packages.x86_64-linux.default;
    };
  };

  # Enable Intel and NVIDIA driver in XServer
  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Force intel-media-driver
  };

}
