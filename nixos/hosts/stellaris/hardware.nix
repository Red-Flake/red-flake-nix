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
  nixpkgs.config.nvidia.acceptLicense = true;

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
    initrd.kernelModules = [ "xe" ]; # load Intel Xe Graphics kernel module at boot
    blacklistedKernelModules = [
      "nouveau"
      "tuxedo_nb02_nvidia_power_ctrl" # blacklist to avoid conflict with nvidia module; the tuxedo module cannot control the power state
    ];
    kernelModules = [
      "xe" # load Intel Xe Graphics kernel module
      "kvm-intel"
      "msr" # /dev/cpu/CPUNUM/msr provides an interface to read and write the model-specific registers (MSRs) of an x86 CPU
      "tuxedo_keyboard"
      "tuxedo-io"
      #"nvidia"   # DO NOT LOAD nvidia module in either initrd or kernelModules; it will still get loaded by nvidia-offload when needed
    ];
    extraModulePackages = with pkgs; [
      linuxKernel.packages.linux_xanmod_latest.tuxedo-drivers
    ];

    # TUXEDO-specific: set keyboard brightness and color at boot
    kernelParams = [
      "tuxedo_keyboard.kbd_backlight_mode=0"
      "tuxedo_keyboard.kbd_backlight_brightness=255"
      "tuxedo_keyboard.kbd_backlight_color_left=0x0000ff"
      "mem_sleep_default=s2idle" # Use s2idle (S0ix) (modern standby) instead of deep (S3) as S3 (Suspend to RAM) is not supported on modern laptops like Core Ultra CPUs, See: https://www.tuxedocomputers.com/en/Power-management-with-suspend-for-current-hardware.tuxedo
      "nvidia-drm.modeset=1" # required for PRIME offload and proper suspend/resume integration with Wayland/XWayland
      "nvidia.NVreg_DynamicPowerManagement=0x02" # Auto mode for power management
      "nvidia.NVreg_PreserveVideoMemoryAllocations=0" # Disable to allow suspend
      "acpi_enforce_resources=lax" # ACPI Lid Non-Compliant: allow legacy driver access, which is a common fix for SW_LID non-compliance without broader ACPI disablement
      "i915.force_probe=*" # [drm] PHY A failed to request refclk after 1us."—Timing issue; force iGPU detection
      "i915.enable_psr=0" # i915 PHY A Refclk Fail: "[drm] PHY A failed to request refclk after 1us"—i915 timing issue; add "i915.enable_psr=0 i915.enable_dc=0" to kernelParams for display/power stability.
      "i915.enable_dc=0" # i915 PHY A Refclk Fail: "[drm] PHY A failed to request refclk after 1us"—i915 timing issue; add "i915.enable_psr=0 i915.enable_dc=0" to kernelParams for display/power stability.
    ];

    # Set extra kernel module options
    extraModprobeConfig = ''
      options kvm_intel nested=1

      # Wi-Fi power tweaks
      options iwlmvm power_scheme=1
      options iwlwifi power_save=0 uapsd_disable=1

      # NVIDIA: Auto mode for power management
      options nvidia NVreg_DynamicPowerManagement=0x02

      # NVIDIA: Disable to allow suspend
      options nvidia NVreg_PreserveVideoMemoryAllocations=0

      # Intel GPU: GuC / HuC firmware for Alder Lake-P (Mobile) and newer
      options i915 enable_guc=3
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

  # For Wayland (KDE), prevent kwin_wayland from using NVIDIA by default.
  # This forces it to use Intel instead, which is more stable and power-efficient
  services.xserver.displayManager.sessionCommands = ''
    export __GLX_VENDOR_LIBRARY_NAME=mesa
    export LIBVA_DRIVER_NAME=iHD
    export VDPAU_DRIVER=va_gl
    export DRI_PRIME=0
  '';

  systemd.services.nvidia-pm-auto = {
    description = "Force NVIDIA GPU runtime PM to auto";
    enable = true;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c 'for devpath in /sys/bus/pci/devices/0000:*; do pciaddr=$(basename $devpath); if lspci -s $pciaddr 2>/dev/null | grep -iq NVIDIA; then ctl=\"$devpath/power/control\"; if [ -f \"$ctl\" ]; then echo auto > \"$ctl\" || true; fi; fi; done'";
    };
    wantedBy = [
      "multi-user.target"
      "sleep.target"
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
    ];
    after = [
      "multi-user.target"
      "sleep.target"
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
    ];
  };

  # Try to suspend Nvidia GPU properly on sleep/suspend/hibernate
  systemd.sleep.extraConfig = ''
    [Sleep]
    AllowSuspend=yes
    AllowHibernation=yes
  '';

  # Extend the existing nvidia-suspend service with your custom script
  # systemd.services.nvidia-suspend = lib.mkIf config.hardware.nvidia.powerManagement.enable {
  #   serviceConfig.ExecStart = lib.mkForce ''
  #     ${pkgs.bash}/bin/bash -c '${pkgs.writeShellScriptBin "nvidia-suspend-custom" ''
  #       #!/bin/sh
  #       case "$1" in
  #         suspend)
  #           # Unload NVIDIA modules to free video memory
  #           ${pkgs.kmod}/bin/modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia || true
  #           ${pkgs.kmod}/bin/modprobe -r nvidia || true
  #           ;;
  #         hibernate)
  #           ${pkgs.kmod}/bin/modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia || true
  #           ${pkgs.kmod}/bin/modprobe -r nvidia || true
  #           ;;
  #         resume|thaw)
  #           ${pkgs.kmod}/bin/modprobe nvidia || true
  #           if [ -d /sys/module/nvidia_modeset ]; then
  #             ${pkgs.kmod}/bin/modprobe nvidia_modeset || true
  #           fi
  #           if [ -d /sys/module/nvidia_drm ]; then
  #             ${pkgs.kmod}/bin/modprobe nvidia_drm || true
  #           fi
  #           if [ -d /sys/module/nvidia_uvm ]; then
  #             ${pkgs.kmod}/bin/modprobe nvidia_uvm || true
  #           fi
  #           ;;
  #       esac
  #     ''}/bin/nvidia-suspend-custom suspend || true'
  #   '';
  #   serviceConfig.ExecStop = lib.mkForce ''
  #     ${pkgs.bash}/bin/bash -c '${pkgs.writeShellScriptBin "nvidia-resume-custom" ''
  #       #!/bin/sh
  #       case "$1" in
  #         resume|thaw)
  #           ${pkgs.kmod}/bin/modprobe nvidia || true
  #           if [ -d /sys/module/nvidia_modeset ]; then
  #             ${pkgs.kmod}/bin/modprobe nvidia_modeset || true
  #           fi
  #           if [ -d /sys/module/nvidia_drm ]; then
  #             ${pkgs.kmod}/bin/modprobe nvidia_drm || true
  #           fi
  #           if [ -d /sys/module/nvidia_uvm ]; then
  #             ${pkgs.kmod}/bin/modprobe nvidia_uvm || true
  #           fi
  #           ;;
  #       esac
  #     ''}/bin/nvidia-resume-custom resume || true'
  #   '';
  # };

  # Enable Intel and NVIDIA driver in XServer
  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "nvidia-sleep.sh" ''
      #!/bin/sh
      case "$1" in
        suspend)
          # Unload NVIDIA modules to free video memory
          ${pkgs.kmod}/bin/modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia || true
          ${pkgs.kmod}/bin/modprobe -r nvidia || true
          ;;
        hibernate)
          ${pkgs.kmod}/bin/modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia || true
          ${pkgs.kmod}/bin/modprobe -r nvidia || true
          ;;
        resume|thaw)
          ${pkgs.kmod}/bin/modprobe nvidia || true
          if [ -d /sys/module/nvidia_modeset ]; then
            ${pkgs.kmod}/bin/modprobe nvidia_modeset || true
          fi
          if [ -d /sys/module/nvidia_drm ]; then
            ${pkgs.kmod}/bin/modprobe nvidia_drm || true
          fi
          if [ -d /sys/module/nvidia_uvm ]; then
              ${pkgs.kmod}/bin/modprobe nvidia_uvm || true
          fi
          ;;
      esac
    '')
  ];

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Force intel-media-driver
    VDPAU_DRIVER = "va_gl"; # Forces Intel via VAAPI
    DRI_PRIME = "0"; # Default to Intel
    __NV_PRIME_RENDER_OFFLOAD = "0"; # Disable offload by default
    __VK_LAYER_NV_optimus = "non_NVIDIA_only"; # Only report non-NVIDIA GPUs to the Vulkan application
    __GLX_VENDOR_LIBRARY_NAME = "mesa"; # Default to Mesa (Intel) for OpenGL
  };

  # HiDPI fixes => https://github.com/NixOS/nixos-hardware/blob/3f7d0bca003eac1a1a7f4659bbab9c8f8c2a0958/common/hidpi.nix
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
  console.earlySetup = lib.mkDefault true;
}
