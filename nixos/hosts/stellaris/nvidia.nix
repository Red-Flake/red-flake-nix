# https://markwatkinson.com/knowledge/linux/nvidia-dgpu-power/

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{

  # Enable Nix cache for CUDA packages
  nix.settings = {
    substituters = [ "https://cuda-maintainers.cachix.org" ];
    trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  boot = {
    # Nvidia-specific: kernel parameters
    # See: https://download.nvidia.com/XFree86/Linux-x86_64/580.65.06/README/dynamicpowermanagement.html
    # Preserving video memory in early KMS fails, see: https://www.reddit.com/r/hyprland/comments/1cyb0h7/hibernate_on_nvidia
    # Do not load nvidia in early KMS (boot.initrd.kernelModules), load via boot.kernelModules instead
    kernelModules = [
      "nvidia"
      "nvidia_drm"
      "nvidia_modeset"
      # "nvidia_uvm" # Don't load it early as it causes power-management issues
    ];

    kernelParams = [
      # NVIDIA PRIME Offloading / suspend helpers
      "nvidia-drm.modeset=1" # Required for PRIME render offload and proper Wayland/XWayland integration
      "nvidia.NVreg_UsePageAttributeTable=1" # nvidia assume that by default your CPU does not support PAT; why this isn't default is beyond me.
      "nvidia.NVreg_InitializeSystemMemoryAllocations=0" # Disable pre-allocation of system memory for pinned allocations; helps with memory fragmentation
      "nvidia.NVreg_DeviceFileUID=0" # Set device file ownership to root
      "nvidia.NVreg_DeviceFileGID=26" # 26 is the GID of the "video" group on NixOS
      "nvidia.NVreg_DeviceFileMode=0660" # Set device file permissions to rw-rw----
      "nvidia.NVreg_EnableS0ixPowerManagement=1" # Enable S0ix support in NVIDIA driver
      "nvidia.NVreg_DynamicPowerManagement=0x02" # Enable dynamic power management to let TCC control power limits (0x01=disabled, 0x02=auto, 0x03=always on)
      "nvidia.NVreg_DynamicPowerManagementVideoMemoryThreshold=0"
      "nvidia.NVreg_S0ixPowerManagementVideoMemoryThreshold=16384" # 16 GiB; > 12 GiB VRAM, so always copy vram to /dev/shm + power-off
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1" # Preserve video memory across suspend/resume; required for stable S0ix
      "nvidia.NVreg_TemporaryFilePath=/dev/shm" # Path to save VRAM contents during suspend; /dev/shm is 47G and VRAM is 12G
    ];
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
      powerManagement.enable = true; # https://github.com/NVIDIA/open-gpu-kernel-modules/issues/472
      # [  363.611590] NVRM: GPU 0000:02:00.0: PreserveVideoMemoryAllocations module parameter is set. System Power Management attempted without driver procfs suspend interface. Please refer to the 'Configuring Power Management Support' section in the driver README.

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

      # Disable NVIDIA persistence mode so the driver can be unloaded when not in use.
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

  # Custom udev rules for NVIDIA GPU
  # See: https://download.nvidia.com/XFree86/Linux-x86_64/580.65.06/README/dynamicpowermanagement.html
  services.udev.extraRules = ''
    # Remove NVIDIA USB xHCI Host Controller devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{remove}="1"

    # Remove NVIDIA USB Type-C UCSI devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{remove}="1"

    # Remove NVIDIA Audio devices, if present
    # ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"

    # Enable runtime PM for NVIDIA VGA/3D controller devices on driver bind
    ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
    ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"

    # Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
    ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"
  '';

  # Enable NVIDIA Dynamic Boost for automatic CPU/GPU power management
  hardware.nvidia.dynamicBoost.enable = true;

  # Enable nvidia-suspend service
  systemd.services.nvidia-suspend = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.mkForce "${config.boot.kernelPackages.nvidiaPackages.latest}/bin/nvidia-sleep.sh suspend";
    };
    before = [ "systemd-suspend.service" ];
    wantedBy = [ "suspend.target" ];
  };

  systemd.services.nvidia-hibernate = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.mkForce "${config.boot.kernelPackages.nvidiaPackages.latest}/bin/nvidia-sleep.sh hibernate";
    };
    before = [ "systemd-hibernate.service" ];
    wantedBy = [ "hibernate.target" ];
  };

  systemd.services.nvidia-resume = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.mkForce "${config.boot.kernelPackages.nvidiaPackages.latest}/bin/nvidia-sleep.sh resume";
    };
    after = [
      "systemd-suspend.service"
      "systemd-hibernate.service"
    ];
    wantedBy = [
      "suspend.target"
      "hibernate.target"
    ];
  };
}
