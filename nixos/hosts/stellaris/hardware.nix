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
      #"i915" # don't blacklist i915. i915.force_probe=!7d67 already prevents i915 from binding to the iGPU
      "spd5118" # blacklist to avoid these issues: [  146.522972] spd5118 14-0050: Failed to write b = 0: -6    [  146.522974] spd5118 14-0050: PM: dpm_run_callback(): spd5118_resume [spd5118] returns -6     [  146.522978] spd5118 14-0050: PM: failed to resume async: error -6
    ];
    kernelModules = [
      "kvm-intel"
      "msr" # /dev/cpu/CPUNUM/msr provides an interface to read and write the model-specific registers (MSRs) of an x86 CPU
      "tuxedo_keyboard"
      "tuxedo_io"
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

      # Intel i915: Disable Display Power Savings
      "i915.enable_fbc=0"
      "i915.enable_psr=0"
      "i915.enable_dc=0"

      # Intel Xe: Quiet the FBC/PSR noise / flicker; Disable xe DC states
      "xe.enable_fbc=0"
      "xe.enable_psr=0"
      "xe.enable_dc=0"
      #"xe.enable_sagv=0" # Disable SAGV (System Agent voltage/frequency scaling) for stability

      # Intel Xe (i915): Load GuC + HuC
      # Force Xe driver to load GuC + HuC (bitmask: 1=GuC submission, 2=HuC → 3=both)
      #"xe.guc_load=3"
      "i915.enable_guc=3" # Same bitmask (GuC+HuC)

      # Intel Xe: Quiet GuC firmware logs
      #"xe.guc_log_level=0"

      # Intel Xe: Disable verbose HW state warnings (hides non-fatal TLB WARN_ON)
      #"xe.verbose_state_checks=0"

      # Intel Xe: Keep the driver default wedged policy (avoids kernel taint from wedged_mode=0)

      # Quiet Intel Xe DRM debug kernel log spam (TLB/PHY refclk issues...)
      #"drm.debug=0x0"

      # Workarounds for Intel `xe` TLB invalidation fence timeouts / PHY refclk hiccups.
      # Disable SAGV (System Agent voltage/frequency scaling) for stability.
      "xe.enable_sagv=0"
      # Disable Panel Replay / PSR2 selective fetch. Some panels/firmware combos misbehave here.
      "xe.enable_panel_replay=0"
      "xe.enable_psr2_sel_fetch=0"
      "xe.psr_safest_params=1"
      # Keep display power wells on (avoid refclk/power-well related glitches at the cost of power).
      "xe.disable_power_well=0"

      # Intel Hybrid perf
      "intel_pstate=passive" # Let userspace (TUXEDO Control Center / TLP) manage P-states for Intel hybrid CPUs

      # Select full kernel preemption via PREEMPT_DYNAMIC: lets higher‑prio tasks preempt most kernel code -> lower latency/better interactivity, small throughput/overhead cost.
      #"preempt=full"

      # Prefer THP madvise for desktop/gaming workloads.
      "transparent_hugepage=madvise"

      # Disable split lock detection - some games/apps trigger split locks causing micro-stutter
      "split_lock_detect=off"

      # Let the kernel select the default CPUIdle governor (typically `menu` on tickless systems).
      #"cpuidle.governor=teo"

      # PCIe ASPM: prioritize latency over power saving.
      # Monitor S0ix (s2idle) suspend power draw/residency; disabling ASPM can increase sleep drain on some laptops.
      "pcie_aspm.policy=performance"

      # NVMe: Force PS0-only (disable APST sleep states) for zero-latency IO
      # Eliminates 10-100ms runtime stalls from NVMe power wakeup → fixes IO PSI spikes & desktop "stickiness"
      # Power cost: ~0.5-1W idle
      # Does not affect suspend/lid-close (S0ix/S3 uses separate shutdown sequence)
      "nvme_core.default_ps_max_latency_us=0"

      # Set CAKE network scheduler as default
      "net.core.default_qdisc=cake"
    ];

    # --- extra kernel module options (goes into /etc/modprobe.d/nixos.conf) ---#
    # Keep this minimal: ONLY 'options' lines and no stray prose (avoid multi-line comment blocks that might confuse parsing).
    extraModprobeConfig = ''
      # Make sure MEI is up before xe tries to talk to GSC
      softdep xe pre: mei_gsc_proxy mei_me mei

      # NOTE: xe does not support i915-style guc_load/enable_guc toggles.
      # Keeping driver defaults; see `modinfo -p xe` for available parameters.

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

    # load firmware packages
    firmware = with pkgs; [
      (linux-firmware.overrideAttrs (_oldAttrs: {
        postFixup = ''
          # Arrow Lake-HX Xe2: Ensure we load the exact GuC firmware the kernel expects
          # Found in DRM coredump: `sudo cat /sys/class/drm/card0/device/devcoredump/data | strings`
          # GuC firmware: i915/mtl_guc_70.bin
          # GuC version: 70.53.0 (wanted 70.44.1)
          # Arrow Lake-HX Xe2 (PCI 0x7d67): Downgrade to exact GuC v70.44.1 kernel wants
          # Source: git.kernel.org i915/mtl_guc_70.bin (historical commit with v70.44.1)
          cp ${pkgs.fetchurl {
            url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/i915/mtl_guc_70.bin";
            sha256 = "sha256-d5Twtqvl/NnG9HA12v4hmfMKbn0jC9WlP7+ABaYOWRE=";  # nix-prefetch-url "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/i915/mtl_guc_70.bin" | xargs nix hash to-sri --type sha256
          }} $out/lib/firmware/i915/mtl_guc_70.bin

          # HuC for GT1 media (Firefox VAAPI): Standard Meteor/Arrow Lake
          cp ${pkgs.fetchurl {
            url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/i915/mtl_huc_gsc.bin";
            sha256 = "sha256-PqI/OelGEi0URlZdGgfAhmvz48iBm0MTSSU3HYd8pM0=";  # nix-prefetch-url "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/i915/mtl_huc_gsc.bin" | xargs nix hash to-sri --type sha256
          }} $out/lib/firmware/i915/mtl_huc_gsc.bin
        '';
      }))
    ];

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

    # Enable Bluetooth
    bluetooth.enable = true;

    # TUXEDO-specific: drivers, Keyboard lighting and fan control (from nixpkgs)
    tuxedo-drivers.enable = true;
    tuxedo-rs = {
      # Important: disable tuxedo-rs and tailor-gui to avoid conflict with tuxedo-drivers and tuxedo-control-center
      enable = lib.mkForce false;
      tailor-gui.enable = lib.mkForce false; # GUI for TUXEDO Control Center equivalent
    };
    tuxedo-control-center = {
      enable = false; # Disable original TUXEDO Control Center via tuxedo-nixos
      package = inputs.tuxedo-nixos.packages.x86_64-linux.default;
    };
  };

  # Enable Uniwill Control Center
  # https://github.com/nanomatters/ucc
  services.uccd = {
    enable = true;
  };

  # Fix TCC service missing commands
  #systemd.services.tccd = {
  # Add missing utilities to PATH for TCC to work properly
  #  path = with pkgs; [
  #    coreutils # provides 'users', 'cat', etc.
  #    util-linux # provides additional system utilities
  #    procps # provides process utilities
  #  ];
  #};

  # Fix tccd-sleep.service: upstream has broken ExecStart/ExecStop with quoted commands
  #systemd.services.tccd-sleep = {
  #  serviceConfig = {
  #    ExecStart = lib.mkForce "${pkgs.systemd}/bin/systemctl stop tccd";
  #    ExecStop = lib.mkForce "${pkgs.systemd}/bin/systemctl start tccd";
  #  };
  #};

  services.xserver = {
    # For Wayland (KDE), prevent kwin_wayland from using NVIDIA by default.
    # This forces it to use Intel instead, which is more stable and power-efficient
    displayManager.sessionCommands = ''
      export LIBVA_DRIVER_NAME=iHD
      export VDPAU_DRIVER=va_gl
      export MESA_LOADER_DRIVER_OVERRIDE=iris
      export __GLX_VENDOR_LIBRARY_NAME=mesa
      export ANV_ENABLE_PIPELINE_CACHE=1
      export NIXOS_OZONE_WL=1

      # Don't set PRIME/NVIDIA variables globally - let apps default to Intel
      # Steam and other apps can override these as needed
    '';

    # Enable Intel & NVIDIA driver in XServer
    videoDrivers = [
      "modesetting"
      "nvidia"
    ];

    # Set DPI to 147
    dpi = 147; # Stellaris 16 2560x1600 ~188PPI logical 147 @150%
  };

  services.thermald.enable = lib.mkForce false; # Thermal management

  services.auto-cpufreq.enable = lib.mkForce false; # Disable if using TLP / TCCD / UCCD

  # Make sure nothing else fights TLP
  # default is `on` on Gnome / KDE, and prevents using tlp:
  # https://discourse.nixos.org/t/cant-enable-tlp-when-upgrading-to-21-05/13435
  services.power-profiles-daemon.enable = lib.mkForce false;

  powerManagement = {
    enable = lib.mkForce true;
    powertop.enable = lib.mkForce false;
  };

  # On hybrid CPUs (P/E-cores), irqbalance can be a win or a loss depending on workload/power goals.
  # Keep it off by default for laptop power behavior, but make it easy to A/B test via a specialisation.
  services.irqbalance.enable = lib.mkDefault false;

  # Disable earlyoom on this machine. earlyoom kills at 5% RAM/ZRAM—too aggressive for 96GB + zram100%.
  services.earlyoom = {
    enable = lib.mkForce false;
  };

  # Enable the usbmuxd ("USB multiplexing daemon") service. This daemon is in charge of multiplexing connections over USB to an iOS device.
  services.usbmuxd.enable = true;

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Force intel-media-driver; Quick Sync decode/encode
    VDPAU_DRIVER = "va_gl"; # Forces Intel via VAAPI; VDPAU → VAAPI fallback
    MESA_LOADER_DRIVER_OVERRIDE = "iris"; # Xe OpenGL/Vulkan (not anv; iris=Gen12+)
    __GLX_VENDOR_LIBRARY_NAME = "mesa"; # Mesa GLX (avoid Nouveau/NVIDIA proprietary)
    ANV_ENABLE_PIPELINE_CACHE = "1"; # Enable Vulkan pipeline caching; Vulkan cache speedup
    NIXOS_OZONE_WL = "1"; # Hint Electron/Chromium apps to use Wayland natively
    # mesa_glthread = "true"; # Disabled: causes KWin CPU spikes with Intel Xe driver
    # Don't set PRIME/NVIDIA variables globally - let apps default to Intel
    # Steam and other apps can override these as needed

    # KWin Wayland fixes for Intel Xe (Arrow Lake)
    #KWIN_DRM_OVERRIDE_SAFETY_MARGIN = "1500"; # ~45% of frame time (3333µs @ 300Hz); default is 1500µs
    #KWIN_DRM_NO_AMS = "1"; # Disable Atomic Mode Setting to reduce CPU usage during animations; DISABLED: causes slow kwin rendering
    #KWIN_FORCE_SW_CURSOR = "0"; # Use hardware cursor (Intel Xe defaults to software cursor);
    KWIN_DRM_DEVICES = "/dev/dri/card0:/dev/dri/card1"; # (Intel: card0 first, NVIDIA: card1 second)
  };

  # HiDPI fixes => https://github.com/NixOS/nixos-hardware/blob/3f7d0bca003eac1a1a7f4659bbab9c8f8c2a0958/common/hidpi.nix
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
  console.earlySetup = lib.mkDefault true;

  # Host-specific udev rules for NVMe optimization
  services.udev.extraRules = lib.mkAfter ''
    # All NVMe SSDs: Kyber + low-latency for smooth UI/gaming (9100 Pro optimized)
    ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="nvme*n*", ENV{DEVTYPE}=="disk", \
      ATTR{queue/scheduler}="kyber", \
      ATTR{queue/nr_requests}="32", \
      ATTR{queue/rq_affinity}="2", \
      ATTR{queue/iosched/read_lat_nsec}="2000000", \
      ATTR{queue/iosched/write_lat_nsec}="10000000", \
      ATTR{queue/read_ahead_kb}="128"

    # ZFS partitions on NVMe: Re-apply parent settings (handles pool changes)
    ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="nvme*n*p*", ENV{ID_FS_TYPE}=="zfs_member", \
      ATTR{../queue/scheduler}="kyber", \
      ATTR{../queue/nr_requests}="32", \
      ATTR{../queue/rq_affinity}="2", \
      ATTR{../queue/iosched/read_lat_nsec}="2000000", \
      ATTR{../queue/iosched/write_lat_nsec}="10000000", \
      ATTR{../queue/read_ahead_kb}="128"

    # Samsung NVMe: Extra iomem relaxation (Gen5 perf boost)
    ACTION=="add|change", SUBSYSTEM=="nvme", ATTR{vendor}=="0x144d", ATTR{model}=="Samsung SSD 9100 PRO*", \
      ATTR{device/iomem_policy}="relaxed"
  '';
}
