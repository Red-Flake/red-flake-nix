{
  config,
  lib,
  pkgs,
  inputs,
  tuxedo-nixos,
  ...
}:
{
  # Accept the NVIDIA license
  nixpkgs.config.nvidia.acceptLicense = true;

  # Enable CUDA support
  nixpkgs.config.cudaSupport = true;

  boot = {
    # TUXEDO-specific: kernel parameters
    kernelParams = [
      # NVIDIA PRIME Offloading / suspend helpers
      "nvidia-drm.modeset=1" # Required for PRIME render offload and proper Wayland/XWayland integration
      "nvidia.NVreg_EnableS0ixPowerManagement=1" # Enable S0ix support in NVIDIA driver
      "nvidia.NVreg_DynamicPowerManagement=0x02" # Auto dynamic power management (0x01=disabled, 0x02=auto, 0x03=always on)
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1" # Preserve video memory across suspend/resume; required for stable S0ix
      "nvidia.NVreg_TemporaryFilePath=/tmp" # Path to save VRAM contents during suspend (ok since /tmp is on ZFS, not tmpfs)
    ];

    # --- extra kernel module options (goes into /etc/modprobe.d/nixos.conf) ---#
    # Keep this minimal: ONLY 'options' lines and no stray prose (avoid multi-line comment blocks that might confuse parsing).
    extraModprobeConfig = ''
      # NVIDIA module options (module-level equivalent of the kernel params above)
      options nvidia NVreg_EnableS0ixPowerManagement=1
      options nvidia NVreg_DynamicPowerManagement=0x02
      options nvidia NVreg_PreserveVideoMemoryAllocations=1
      options nvidia NVreg_TemporaryFilePath=/tmp
    '';

  };

  hardware = {
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
      package = config.boot.kernelPackages.nvidiaPackages.beta;

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

    # Enable Nvidia graphics acceleration
    graphics = {
      extraPackages = with pkgs; [
        vaapiVdpau # For Nvidia VDPAU backend
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        vaapiVdpau # For Nvidia VDPAU backend
      ];
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
    export __NV_PRIME_RENDER_OFFLOAD=0
    export __VK_LAYER_NV_optimus=non_NVIDIA_only
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

  # Enable NVIDIA driver in XServer
  services.xserver.videoDrivers = [
    "nvidia"
  ];

  environment.systemPackages = with pkgs; [
    envycontrol

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
}
