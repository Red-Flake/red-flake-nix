{
  config,
  lib,
  pkgs,
  inputs,
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
    ];
    extraModulePackages = [ ];

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
        libvdpau-va-gl  # VDPAU driver with OpenGL/VAAPI backend
        vpl-gpu-rt  # For Intel QSV (Quick Sync Video)
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        libvdpau-va-gl  # VDPAU driver with OpenGL/VAAPI backend
        vpl-gpu-rt  # For Intel QSV (Quick Sync Video)
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
    tuxedo-drivers.enable = true;
    tuxedo-rs = {
      enable = true;
      tailor-gui.enable = true; # GUI for TUXEDO Control Center equivalent
    };
    tuxedo-keyboard.enable = true;
    tuxedo-control-center.enable = true; # Enable original TUXEDO Control Center via tuxedo-nixos
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
