{ lib
, pkgs
, ...
}:
{

  custom = {
    # disable ZFS encryption
    zfs.encryption = lib.mkForce false;

    # set display resolution to 1080p
    display.resolution = "1080p";
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
      # AMD P-State driver
      "amd_pstate=active"

      # ACPI
      "acpi_enforce_resources=lax"

      # Preemption and memory
      "preempt=full"
      "transparent_hugepage=madvise"

      # PCIe ASPM: prioritize latency over power saving
      "pcie_aspm.policy=performance"

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

  # Recommended to explicitly declare video driver for Xorg and fallback support
  services.xserver.videoDrivers = [ "amdgpu" ];

  environment.variables =
    {
      AMD_VULKAN_ICD = "RADV";
      ROCM_PATH = "${pkgs.rocmPackages.rocm-runtime}";
    };

  environment.systemPackages = with pkgs; [
    # GPU tools
    vulkan-tools
    mesa-demos
    radeontop # AMD GPU utilization monitor
    lm_sensors # For temperature sensors
    pciutils
    clinfo # Verify OpenCL setup

    # ROCm packages
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
    rocmPackages.rocm-smi
    rocmPackages.rocm-cmake
  ];

}
