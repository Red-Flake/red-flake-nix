{ lib
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
    ];

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

    # Make sure you are NOT enabling AMDGPU-PRO OpenCL
    amdgpu.opencl.enable = false;

    amdgpu.initrd.enable = true; # Enable Initrd support

    graphics = {
      enable = true;
      enable32Bit = true;

      # Optional: extra Vulkan ICD and Mesa Vulkan layers, useful for some apps and games
      extraPackages = with pkgs; [
        # AMD OpenCL
        rocmPackages.rocm-runtime
        rocmPackages.rocm-smi
        rocmPackages.rocminfo

        # OpenCL ICD definition for AMD GPUs using the ROCm stack
        rocmPackages.clr.icd

        # OpenCL runtime for AMD GPUs, part of the ROCm stack
        rocmPackages.clr
      ];
    };
  };

  # Some programs hard-code the path to HIP
  #systemd.tmpfiles.rules = [ "L+ /opt/rocm/hip - - - - ${pkgs.rocmPackages.clr}" ];
  systemd.tmpfiles.rules =
    let
      rocmEnv = pkgs.symlinkJoin {
        name = "rocm-combined";
        paths = with pkgs.rocmPackages; [ rocblas hipblas clr ];
      };
    in
    [
      "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
      "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
    ];

  environment.etc."OpenCL/vendors/amdocl64.icd".text =
    "${pkgs.rocmPackages.clr.icd}/lib/libamdocl64.so ";

  services.fstrim.enable = true;

  # Recommended to explicitly declare video driver for Xorg and fallback support
  services.xserver.videoDrivers = [ "amdgpu" ];

  environment.variables =
    {
      AMD_VULKAN_ICD = "RADV";
      ROCM_PATH = "${pkgs.rocmPackages.rocm-runtime}";
    };

  environment.systemPackages = with pkgs;
    [
      vulkan-tools
      mesa-demos
      radeontop # AMD GPU utilization monitor
      lm_sensors # For temperature sensors
      pciutils

      # ------------------------------------------------
      # ---- ROCM Packages
      # ------------------------------------------------
      rocmPackages.clr
      rocmPackages.hip-common
      rocmPackages.hipblas
      rocmPackages.hipcc
      rocmPackages.hipcub
      rocmPackages.hipfft
      rocmPackages.hipify
      rocmPackages.hiprand
      rocmPackages.rocm-runtime
      rocmPackages.rocminfo
      rocmPackages.rpp-opencl

      # ROCm Application for Reporting System Info
      rocmPackages.rocminfo

      # System management interface for AMD GPUs supported by ROCm
      rocmPackages.rocm-smi

      # Platform runtime for ROCm
      rocmPackages.rocm-runtime

      # CMake modules for common build tasks for the ROCm stack
      rocmPackages.rocm-cmake

      # You should also install the clinfo package to verify that OpenCL is correctly setup (or check in the program you use to see if it is now available, such as in Darktable).
      clinfo
    ];

  # Allow firmware Updates
  services.fwupd.enable = true;
}
