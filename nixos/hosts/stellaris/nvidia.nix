# https://markwatkinson.com/knowledge/linux/nvidia-dgpu-power/

{ config
, lib
, pkgs
, pkgsUnstable
, ...
}:
{

  custom.kernel.nvidia.stripFix.enable = true;

  # Enable Nix cache for CUDA packages (append; don't override global caches).
  nix.settings.substituters = lib.mkAfter [ "https://cuda-maintainers.cachix.org" ];
  nix.settings.trusted-public-keys = lib.mkAfter [
    "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
  ];

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

    kernelParams = lib.mkMerge [
      [
        # NVIDIA PRIME Offloading / suspend helpers
        "nvidia-drm.modeset=1" # Required for PRIME render offload and proper Wayland/XWayland integration
        "nvidia.NVreg_UsePageAttributeTable=1" # nvidia assume that by default your CPU does not support PAT; why this isn't default is beyond me.
        "nvidia.NVreg_InitializeSystemMemoryAllocations=0" # Disable pre-allocation of system memory for pinned allocations; helps with memory fragmentation
        "nvidia.NVreg_DeviceFileUID=0" # Set device file ownership to root
        "nvidia.NVreg_DeviceFileGID=26" # 26 is the GID of the "video" group on NixOS
        "nvidia.NVreg_DeviceFileMode=0660" # Set device file permissions to rw-rw----
        "nvidia.NVreg_EnableS0ixPowerManagement=1" # Enable S0ix support in NVIDIA driver

        # Use Message Signaled Interrupts (MSI) instead of traditional line-based interrupts.
        # Reduces CPU overhead and latency; helps prevent "PHY refclk" and timing race 
        # conditions on modern PCIe 5.0 buses (Arrow Lake + Blackwell).
        "nvidia.NVreg_EnableMSI=1"
        # RTD3 (Runtime D3) Power Management - controls GPU power state while system is awake
        # See: https://download.nvidia.com/XFree86/Linux-x86_64/580.65.06/README/dynamicpowermanagement.html
        #
        # Available modes:
        #   0x00 = Disabled: GPU always powered on (uses ~15-30W idle)
        #   0x01 = Coarse-grained: GPU powers off only when NO nvidia apps are running
        #   0x02 = Fine-grained: GPU actively monitored, powers off after short idle periods
        #   0x03 = Default (fine-grained on Ampere+ notebooks, disabled elsewhere)
        #
        # DISABLED (0x00) because:
        # - RTX 50 series (Blackwell) has severe GSP timeout bugs causing system lockups
        #   See: https://github.com/NVIDIA/open-gpu-kernel-modules/issues/1045
        # - Even coarse-grained mode (0x01) can trigger GSP hangs on Blackwell
        # - GPU stays powered on but avoids lockups entirely
        # - Re-enable once NVIDIA fixes GSP issues in a future driver release
        "nvidia.NVreg_DynamicPowerManagement=0x00"
        # Video memory threshold for RTD3: if VRAM usage is below this (in MB), VRAM can be turned off
        # Set to 0 to keep VRAM in self-refresh mode (faster wake, slightly more power) instead of off
        # This reduces RTD3 transition latency and avoids potential issues with VRAM state restoration
        "nvidia.NVreg_DynamicPowerManagementVideoMemoryThreshold=0"
        "nvidia.NVreg_S0ixPowerManagementVideoMemoryThreshold=16384" # 16 GiB; > 12 GiB VRAM, so always copy vram to /dev/shm + power-off
        "nvidia.NVreg_PreserveVideoMemoryAllocations=1" # Preserve video memory across suspend/resume; required for stable S0ix
        "nvidia.NVreg_TemporaryFilePath=/dev/shm" # Path to save VRAM contents during suspend; /dev/shm is 47G and VRAM is 12G
      ]
      # Override NixOS auto-added nvidia-drm.fbdev=1 - not needed since display goes through Intel iGPU
      # Having fbdev enabled prevents the GPU from entering runtime suspend
      (lib.mkAfter [ "nvidia-drm.fbdev=0" ])
    ];

  };

  hardware = {
    # NVIDIA hybrid graphics setup (PRIME offload mode for battery efficiency; switch to sync if needed for performance)
    nvidia = {
      # Blackwell GPUs require GSP (GPU System Processor) firmware to function.
      gsp.enable = true;

      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
      # of just the bare essentials.
      powerManagement.enable = true; # https://github.com/NVIDIA/open-gpu-kernel-modules/issues/472
      # [  363.611590] NVRM: GPU 0000:02:00.0: PreserveVideoMemoryAllocations module parameter is set.
      # System Power Management attempted without driver procfs suspend interface.
      # Please refer to the 'Configuring Power Management Support' section in the driver README.

      # Fine-grained power management (RTD3) - actively monitors GPU and powers off after short idle
      # See: https://download.nvidia.com/XFree86/Linux-x86_64/580.65.06/README/dynamicpowermanagement.html
      #
      # DISABLED because:
      # - RTX 50 series (Blackwell) has known GSP timeout bugs causing system lockups
      #   when the GPU frequently transitions in/out of D3 power state
      #   See: https://github.com/NVIDIA/open-gpu-kernel-modules/issues/1045
      # - Using DynamicPowerManagement=0x00 (disabled) in kernelParams because
      #   even coarse-grained mode (0x01) triggers GSP hangs on Blackwell.
      #   GPU stays powered on at all times — small power cost, no lockups.
      # - This reduces D3 state transitions while still providing power savings
      #
      # Note: This setting controls RTD3 (runtime power management while system is awake).
      # S0ix suspend/resume is handled separately by NVreg_EnableS0ixPowerManagement=1
      # and will continue to work regardless of this setting.
      powerManagement.finegrained = false;

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

      # We'll install a locally fixed nvidia-settings below (upstream build currently
      # fails due to missing `strip` in PATH during the build).
      nvidiaSettings = false;

      # Disable NVIDIA persistence mode so the driver can be unloaded when not in use.
      nvidiaPersistenced = false;

      # Enable NVIDIA Dynamic Boost for automatic CPU/GPU power management
      dynamicBoost.enable = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      # Use NVIDIA driver from nixpkgs-unstable, built against the current kernel
      package = (pkgsUnstable.linuxPackagesFor config.boot.kernelPackages.kernel).nvidiaPackages.latest;

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
        libva-vdpau-driver # For Nvidia VDPAU backend
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva-vdpau-driver # For Nvidia VDPAU backend
      ];
    };
  };

  environment.systemPackages = [
    (config.hardware.nvidia.package.settings.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.binutils ];
      makeFlags = (old.makeFlags or [ ]) ++ [ "STRIP=${pkgs.binutils}/bin/strip" ];
    }))
  ];

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
    # ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
    # ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"

    # Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
    # ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
    # ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"
  '';

  # Enable nvidia-suspend service
  systemd.services.nvidia-suspend = {
    serviceConfig = {
      Type = "oneshot";
      # `nvidia-sleep.sh` ships with `#!/bin/bash`, but NixOS does not guarantee `/bin/bash` exists.
      # If the interpreter is missing, systemd reports ENOENT on the script itself and suspend fails.
      ExecStart = lib.mkForce "${pkgs.bash}/bin/bash ${config.hardware.nvidia.package}/bin/nvidia-sleep.sh suspend";
    };
    before = [ "systemd-suspend.service" ];
    wantedBy = [ "suspend.target" ];
  };

  # ZFS injects nohibernate which prevents the system from hibernating. So we don't need the nvidia-hibernate service
  /*systemd.services.nvidia-hibernate = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.mkForce "${pkgs.bash}/bin/bash ${config.hardware.nvidia.package}/bin/nvidia-sleep.sh hibernate";
    };
    before = [ "systemd-hibernate.service" ];
    wantedBy = [ "hibernate.target" ];
  };*/

  systemd.services.nvidia-resume = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.mkForce "${pkgs.bash}/bin/bash ${config.hardware.nvidia.package}/bin/nvidia-sleep.sh resume";
    };
    after = [
      "systemd-suspend.service"
    ];
    wantedBy = [
      "suspend.target"
    ];
  };

}
