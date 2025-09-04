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

  # Increase the number of parallel build jobs for Nix to 24
  nix.settings.max-jobs = lib.mkForce 24;

  # Accept the NVIDIA license
  nixpkgs.config.nvidia.acceptLicencse = true;

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
    blacklistedKernelModules = ["nouveau"];
    kernelModules = [
      "kvm-intel"
      "msr" # /dev/cpu/CPUNUM/msr provides an interface to read and write the model-specific registers (MSRs) of an x86 CPU
      "tuxedo_keyboard"
      "tuxedo-io"
      "nvidia"
    ];
    extraModulePackages = with pkgs; [
      linuxKernel.packages.linux_xanmod_latest.tuxedo-drivers
    ];

    # TUXEDO-specific: set keyboard brightness and color at boot
    kernelParams = [
      "tuxedo_keyboard.mode=0"
      "tuxedo_keyboard.brightness=255"
      "tuxedo_keyboard.color_left=0x0000ff"
      "mem_sleep_default=deep"
      "nvidia-drm.modeset=1"  # required for PRIME offload and proper suspend/resume integration with Wayland/XWayland
    ];

    # Set extra kernel module options
    extraModprobeConfig = ''
      options kvm_intel nested=1
      options iwlmvm power_scheme=1
      options iwlwifi power_save=0 uapsd_disable=1
    '';
  };

  # Enable CUDA support
  nixpkgs.config.cudaSupport = true;

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
      enable32Bit = true; # For Steam and other 32-bit apps
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        libvdpau-va-gl # VDPAU driver with OpenGL/VAAPI backend
        vpl-gpu-rt # For Intel QSV (Quick Sync Video)
        vaapiVdpau # For Nvidia VDPAU backend
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        libvdpau-va-gl # VDPAU driver with OpenGL/VAAPI backend
        vaapiVdpau # For Nvidia VDPAU backend
      ];
    };

    # NVIDIA hybrid graphics setup (PRIME offload mode for battery efficiency; switch to sync if needed for performance)
    nvidia = {
      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
      # of just the bare essentials.
      powerManagement.enable = true;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = true;

      # Use the Nvidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of 
      # supported GPUs is at: 
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
      # Only available from driver 515.43.04+
      # An important note to take is that the option hardware.nvidia.open
      # should only be set to false if you have a GPU with an older
      # architecture than Turing (older than the RTX 20-Series). 
      open = true;

      # Enable the Nvidia settings menu,
	    # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      # Disable NVIDIA persistence mode so hopefully the GPU powers down when not in use.
      nvidiaPersistenced = false;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.latest;

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

  # Force runtime PM for the PCI device
  # Create a udev rule so the GPU defaults to auto instead of on
  services.udev.extraRules = ''
    SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{power/control}="auto"
  '';

  systemd.services.nvidia-pm-auto = {
    description = "Force NVIDIA GPU runtime PM to auto";
    enable = true;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c 'for devpath in /sys/bus/pci/devices/0000:*; do pciaddr=$(basename $devpath); if lspci -s $pciaddr 2>/dev/null | grep -iq NVIDIA; then ctl=\"$devpath/power/control\"; if [ -f \"$ctl\" ]; then echo auto > \"$ctl\" || true; fi; fi; done'";
    };
    wantedBy = [ "multi-user.target" "sleep.target" "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    after = [ "multi-user.target" "sleep.target" "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
  };

  # Enable Intel and NVIDIA driver in XServer
  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Force intel-media-driver
  };

  # HiDPI fixes => https://github.com/NixOS/nixos-hardware/blob/3f7d0bca003eac1a1a7f4659bbab9c8f8c2a0958/common/hidpi.nix
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
  console.earlySetup = lib.mkDefault true;
}
