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
      "msr"
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
      "tuxedo-io"
    ];
    extraModulePackages = with pkgs; [
      linuxKernel.packages.linux_xanmod_latest.tuxedo-drivers
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
    ];

    # --- extra kernel module options (goes into /etc/modprobe.d/nixos.conf) ---#
    # Keep this minimal: ONLY 'options' lines and no stray prose (avoid multi-line comment blocks that might confuse parsing).
    extraModprobeConfig = ''
      # Make sure MEI is up before xe tries to talk to GSC
      softdep xe pre: mei_gsc_proxy mei_me mei

      # Quiet the FBC/PSR noise / flicker
      options xe enable_fbc=0
      options xe enable_psr=0

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

  services.thermald.enable = lib.mkForce true; # Thermal management

  #services.auto-cpufreq.enable = lib.mkForce false; # Disable if using TLP + performance governor

  # Make sure nothing else fights TLP
  # default is `on` on Gnome / KDE, and prevents using tlp:
  # https://discourse.nixos.org/t/cant-enable-tlp-when-upgrading-to-21-05/13435
  services.power-profiles-daemon.enable = lib.mkForce false;

  powerManagement = {
    enable = lib.mkForce true;
    powertop.enable = lib.mkForce false;
  };

  # IRQ balance for multi-core performance
  services.irqbalance.enable = lib.mkForce true;

  # Let TCC handle CPU power management
  # TLP settings optimized for intel hybrid CPU architecture for max performance
  #services.tlp.enable = true;
  #services.tlp.settings = {
  ## Intel P-State / HWP
  #CPU_DRIVER_OPMODE_ON_AC = "active";
  #CPU_DRIVER_OPMODE_ON_BAT = "active";

  # https://discourse.nixos.org/t/how-to-switch-cpu-governor-on-battery-power/8446/4
  # https://linrunner.de/tlp/settings/processor.html
  # set CPU governor to performance; for Intel hybrid architecture
  #CPU_SCALING_GOVERNOR_ON_AC = "performance"; # schedutil governor is not exposed if we set intel_pstate=active since P-states are managed by hardware then.
  #CPU_SCALING_GOVERNOR_ON_BAT = "performance"; # schedutil governor is not exposed if we set intel_pstate=active since P-states are managed by hardware then.

  # HWP dynamic boost + Turbo always ON
  #INTEL_HWP_DYN_BOOST_ON_AC = 1;
  #INTEL_HWP_DYN_BOOST_ON_BAT = 1;
  #CPU_BOOST_ON_AC = 1;
  #CPU_BOOST_ON_BAT = 1;

  # EPP = performance on AC *and* battery
  #CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
  #CPU_ENERGY_PERF_POLICY_ON_BAT = "performance";

  #CPU_HWP_ON_AC = "performance";
  #CPU_HWP_ON_BAT = "performance";

  # Force minimum performance 100% (aggressive)
  # If temps are too high, drop BAT to 0–30 later.
  #CPU_MIN_PERF_ON_AC = 100;
  #CPU_MAX_PERF_ON_AC = 100;
  #CPU_MIN_PERF_ON_BAT = 100;
  #CPU_MAX_PERF_ON_BAT = 100;

  # Ask the platform for performance profile if supported (Plasma/TUXEDO FW honors this)
  #PLATFORM_PROFILE_ON_AC = "performance";
  #PLATFORM_PROFILE_ON_BAT = "performance";

  ## I/O and bus power features forced to performance everywhere
  #PCIE_ASPM_ON_AC = "performance";
  #PCIE_ASPM_ON_BAT = "performance";
  #SATA_LINKPWR_ON_AC = "max_performance";
  #SATA_LINKPWR_ON_BAT = "max_performance";

  # Don’t autosuspend USB devices (reduces wake latency)
  #USB_AUTOSUSPEND = 0;

  # Runtime PM: keep devices ‘on’ (lowest latency)
  # https://linrunner.de/tlp/settings/runtimepm.html
  #RUNTIME_PM_ON_AC = "on";
  #RUNTIME_PM_ON_BAT = "on";

  # Wi-Fi power saving off (you already set iwlwifi module opts; this reinforces it)
  # https://github.com/linrunner/TLP/issues/122
  # https://linrunner.de/tlp/settings/network.html
  #WIFI_PWR_ON_AC = "off";
  #WIFI_PWR_ON_BAT = "off";

  # Don’t enable scheduler powersave modes
  #SCHED_POWERSAVE_ON_AC = 0;
  #SCHED_POWERSAVE_ON_BAT = 0;

  # (Optional) Tiny jitter reduction
  #NMI_WATCHDOG = 0;
  #};

  # Let TCC handle HWP Boost
  # Force HWP boost and EPP
  # systemd.services.intel-hwp-boost = {
  #   description = "Re-assert Intel HWP boost and EPP after TLP/TUXEDO";
  #   wantedBy = [
  #     "multi-user.target"
  #     "sleep.target"
  #   ];
  #   after = [
  #     "tlp.service"
  #     # "tuxedo-control-center.service"     ## Disable "CPU Frequency Control" in TCC
  #     "sleep.target"
  #     "systemd-logind.service"
  #   ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = pkgs.writeShellScript "intel-hwp-boost.sh" ''
  #       #!/run/current-system/sw/bin/bash
  #       set -euo pipefail
  #       log() { echo "[intel-hwp-boost] $*"; }

  #       # small delay to avoid races
  #       sleep 2

  #       # HWP dynamic boost
  #       if [ -w /sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost ]; then
  #         for i in {1..5}; do
  #           if echo 1 > /sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost 2>/dev/null; then
  #             break
  #           fi
  #           sleep 1
  #         done
  #       fi

  #       # Prefer policy* nodes (authoritative), also try cpu* aliases
  #       for f in /sys/devices/system/cpu/cpufreq/policy*/energy_performance_preference; do
  #         [ -w "$f" ] && echo performance > "$f" 2>/dev/null || true
  #       done
  #       for f in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
  #         [ -w "$f" ] && echo performance > "$f" 2>/dev/null || true
  #       done

  #       log "Done: HWP boost + EPP=performance applied."
  #     '';
  #     RemainAfterExit = true;
  #   };
  # };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Force intel-media-driver
    VDPAU_DRIVER = "va_gl"; # Forces Intel via VAAPI
    # Don't set PRIME/NVIDIA variables globally - let apps default to Intel
    # Steam and other apps can override these as needed
  };

  # HiDPI fixes => https://github.com/NixOS/nixos-hardware/blob/3f7d0bca003eac1a1a7f4659bbab9c8f8c2a0958/common/hidpi.nix
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
  console.earlySetup = lib.mkDefault true;
}
