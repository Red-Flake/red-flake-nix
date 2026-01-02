{ config
, lib
, pkgs
, inputs
, ...
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

  nix.settings = {
    # Increase the number of parallel build jobs for Nix to 24
    max-jobs = lib.mkForce 24;

    # Enable system features for better performance based on the CPU features
    system-features = [
      "nixos-test"
      "benchmark"
      "kvm"
      "big-parallel"
      "gccarch-arrowlake"
      "gccarch-x86-64-v3"
    ];
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
    ];
    initrd.kernelModules = [
      "mei" # Make sure MEI is up before xe tries to talk to GSC
      "mei_me"
      "mei_gsc_proxy"
      "xe"
    ];
    blacklistedKernelModules = [
      "nouveau"
      "nvidiafb"
      "rivafb"
      "i915" # blacklist old i915 driver for Arrow Lake; xe driver handles Intel graphics
      "spd5118" # blacklist to avoid these issues: [  146.522972] spd5118 14-0050: Failed to write b = 0: -6    [  146.522974] spd5118 14-0050: PM: dpm_run_callback(): spd5118_resume [spd5118] returns -6     [  146.522978] spd5118 14-0050: PM: failed to resume async: error -6
    ];
    kernelModules = [
      "kvm-intel"
      "msr" # /dev/cpu/CPUNUM/msr provides an interface to read and write the model-specific registers (MSRs) of an x86 CPU
      "tuxedo_keyboard"
      "tuxedo_io"
      "uniwill_wmi"
    ];
    extraModulePackages = with config.boot.kernelPackages; [
      tuxedo-drivers # TUXEDO-specific drivers
      r8125 # Realtek 2.5GbE Ethernet driver
    ];

    # TUXEDO-specific: kernel parameters
    kernelParams = [
      # ACPI / keyboard
      "acpi_enforce_resources=lax" # Allow legacy driver access to ACPI resources; fixes non-compliant SW_LID implementations on some laptops

      # Modern standby / suspend
      "mem_sleep_default=s2idle" # Use s2idle (a.k.a. S0ix / modern standby) instead of deep (S3); Core Ultra CPUs don’t support S3
      # See: https://www.tuxedocomputers.com/en/Power-management-with-suspend-for-current-hardware.tuxedo

      # Intel Xe / i915 binding for Meteor Lake / Arrow Lake
      "i915.force_probe=!7d67" # Prevent old i915 driver from binding this GPU
      "xe.force_probe=7d67" # Force the new xe driver to bind the Meteor Lake device (PCI ID 7d67)

      # Intel Hybrid perf
      "intel_pstate=passive" # Let userspace (TUXEDO Control Center / TLP) manage P-states for Intel hybrid CPUs

      # Select full kernel preemption via PREEMPT_DYNAMIC: lets higher‑prio tasks preempt most kernel code -> lower latency/better interactivity, small throughput/overhead cost.
      "preempt=full"

      # Offload RCU callbacks to dedicated kernel threads for lower latency
      "rcu_nocbs=all"

      # Prefer THP madvise for desktop/gaming workloads.
      "transparent_hugepage=madvise"

      # Disable split lock detection - some games/apps trigger split locks causing micro-stutter
      "split_lock_detect=off"
    ];

    # --- extra kernel module options (goes into /etc/modprobe.d/nixos.conf) ---#
    # Keep this minimal: ONLY 'options' lines and no stray prose (avoid multi-line comment blocks that might confuse parsing).
    extraModprobeConfig = ''
      # Make sure MEI is up before xe tries to talk to GSC
      softdep xe pre: mei_gsc_proxy mei_me mei

      # Quiet the FBC/PSR noise / flicker; Disable xe DC states
      options xe enable_fbc=0 enable_psr=0 enable_dc=0

      # Virtualization
      options kvm_intel nested=1

      # Wi-Fi / power
      options iwlmvm power_scheme=1
      options iwlwifi power_save=0 uapsd_disable=1

      # TUXEDO keyboard module: set these as module options (NOT kernel cmdline)
      options tuxedo_keyboard kbd_backlight_mode=0
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
      enable32Bit = true; # For Steam and other 32-bit apps
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        vpl-gpu-rt # For Intel QSV (Quick Sync Video)
      ];
      extraPackages32 = with pkgs.driversi686Linux; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
      ];
    };

    # TUXEDO-specific: drivers, Keyboard lighting and fan control (from nixpkgs)
    # Force disable to avoid conflict with extraModulePackages overlay version
    # (tuxedo-control-center automatically enables this, so we need to override it)
    tuxedo-drivers.enable = lib.mkForce false;
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

  # Fix TCC service missing commands
  systemd.services.tccd = {
    # Add missing utilities to PATH for TCC to work properly
    path = with pkgs; [
      coreutils # provides 'users', 'cat', etc.
      util-linux # provides additional system utilities
      procps # provides process utilities
    ];
  };

  # Fix tccd-sleep.service: upstream has broken ExecStart/ExecStop with quoted commands
  systemd.services.tccd-sleep = {
    serviceConfig = {
      ExecStart = lib.mkForce "${pkgs.systemd}/bin/systemctl stop tccd";
      ExecStop = lib.mkForce "${pkgs.systemd}/bin/systemctl start tccd";
    };
  };

  # For Wayland (KDE), prevent kwin_wayland from using NVIDIA by default.
  # This forces it to use Intel instead, which is more stable and power-efficient
  services.xserver.displayManager.sessionCommands = ''
    export LIBVA_DRIVER_NAME=iHD
    export VDPAU_DRIVER=va_gl
    # Don't set PRIME/NVIDIA variables globally - let apps default to Intel
    # Steam and other apps can override these as needed
  '';

  # Enable Intel & NVIDIA driver in XServer
  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];

  services.thermald.enable = lib.mkForce false; # Thermal management

  #services.auto-cpufreq.enable = lib.mkForce false; # Disable if using TLP + performance governor

  # Make sure nothing else fights TLP
  # default is `on` on Gnome / KDE, and prevents using tlp:
  # https://discourse.nixos.org/t/cant-enable-tlp-when-upgrading-to-21-05/13435
  services.power-profiles-daemon.enable = lib.mkForce false;

  powerManagement = {
    enable = lib.mkForce true;
    powertop.enable = lib.mkForce false;
  };

  # Disable irqbalance since it is bad for Gaming, low-latency, discrete GPUs, anything needing stable and predictable IRQ placement
  services.irqbalance.enable = lib.mkForce false;

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Force intel-media-driver
    VDPAU_DRIVER = "va_gl"; # Forces Intel via VAAPI
    ANV_ENABLE_PIPELINE_CACHE = "1"; # Enable Vulkan pipeline caching
    # mesa_glthread = "true"; # Disabled: causes KWin CPU spikes with Intel Xe driver
    # Don't set PRIME/NVIDIA variables globally - let apps default to Intel
    # Steam and other apps can override these as needed

    # KWin Wayland fixes for Intel Xe (Arrow Lake)
    KWIN_DRM_OVERRIDE_SAFETY_MARGIN = "400"; # Lower latency (try 1000-3000 if frame drops occur); 0.4ms instead of >1ms; Tuned for 300Hz (3.33ms frame time)
    #KWIN_DRM_NO_AMS = "1"; # Disable Atomic Mode Setting to reduce CPU usage during animations; DISABLED: causes slow kwin rendering
    #KWIN_FORCE_SW_CURSOR = "0"; # Use hardware cursor (Intel Xe defaults to software cursor); DISABLED: causes slow kwin rendering
  };

  # HiDPI fixes => https://github.com/NixOS/nixos-hardware/blob/3f7d0bca003eac1a1a7f4659bbab9c8f8c2a0958/common/hidpi.nix
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
  console.earlySetup = lib.mkDefault true;
}
