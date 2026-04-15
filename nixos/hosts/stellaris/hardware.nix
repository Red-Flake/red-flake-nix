{ config
, lib
, pkgs
, ...
}:
{
  # Override linux-firmware globally so enableAllFirmware uses our patched version
  # Also override tuxedo-drivers to fix compatibility with Linux 6.19+
  nixpkgs.overlays = [
    # Overlay 1: Update tuxedo-drivers to 4.21.2 for Linux 6.19 compatibility
    (final: prev: {
      linuxKernel = prev.linuxKernel // {
        packagesFor = kernel:
          (prev.linuxKernel.packagesFor kernel).extend (_: lpPrev: {
            # Change the underscore (_) to 'oldAttrs' below
            tuxedo-drivers = lpPrev.tuxedo-drivers.overrideAttrs (oldAttrs: {
              version = "4.21.2";
              src = final.fetchFromGitLab {
                group = "tuxedocomputers";
                owner = "development/packages";
                repo = "tuxedo-drivers";
                rev = "v4.21.2";
                hash = "sha256-KMn3O3Rq8LaZAgr6R7zNeBn637zZDFD2E2X+a3zKN3s=";
              };

              # Now oldAttrs.postPatch is correctly in scope
              postPatch = (oldAttrs.postPatch or "") + ''
                # Add your specific Board Name to the IO whitelist
                # cat /sys/class/dmi/id/board_name
                sed -i '/static const char \*board_names\[\] = {/a \    "X6AR5xxY",' src/tuxedo_io/tuxedo_io.c

                # Add your Product Name to the internal matching table
                # at /sys/class/dmi/id/product_name
                sed -i '/"TUXEDO Stellaris 16 Intel Gen6",/a \    "TUXEDO Stellaris 16 Intel Gen7",' src/tuxedo_io/tuxedo_io.c
              '';

              # v4.21.2 moved udev rules to files/usr/lib/udev/rules.d/
              postInstall = ''
                substituteInPlace files/usr/lib/udev/rules.d/* \
                  --replace-quiet "/bin/bash" "${final.lib.getExe final.bash}" \
                  --replace-quiet "/bin/sh" "${final.lib.getExe final.bash}"
                install -Dm 0644 -t $out/etc/udev/rules.d files/usr/lib/udev/rules.d/*
              '';
            });
          });
      };
    })

    # Overlay 2: Patch linux-firmware with correct GuC/HuC/GSC versions for Arrow Lake
    (final: prev: {
      linux-firmware = prev.linux-firmware.overrideAttrs (oldAttrs: {
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ final.zstd ];
        postInstall = (oldAttrs.postInstall or "") + ''
          # Arrow Lake-HX Xe2: Override GuC firmware with specific version
          # The default linux-firmware may have a version that causes TLB invalidation timeouts.
          # This replaces the firmware BEFORE compression happens.
          #
          # Check DRM coredump for firmware version mismatches:
          #   sudo cat /sys/class/drm/card0/device/devcoredump/data | strings

          # GuC firmware for Meteor Lake / Arrow Lake Xe
          rm -f $out/lib/firmware/i915/mtl_guc_70.bin $out/lib/firmware/i915/mtl_guc_70.bin.zst 2>/dev/null || true
          cp ${final.fetchurl {
            url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/i915/mtl_guc_70.bin";
            sha256 = "sha256-d5Twtqvl/NnG9HA12v4hmfMKbn0jC9WlP7+ABaYOWRE="; # nix-prefetch-url "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/i915/mtl_guc_70.bin" | xargs nix hash to-sri --type sha256
          }} $out/lib/firmware/i915/mtl_guc_70.bin

          # HuC firmware for GT1 media (Firefox VAAPI)
          rm -f $out/lib/firmware/i915/mtl_huc_gsc.bin $out/lib/firmware/i915/mtl_huc_gsc.bin.zst 2>/dev/null || true
          cp ${final.fetchurl {
            url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/i915/mtl_huc_gsc.bin";
            sha256 = "sha256-PqI/OelGEi0URlZdGgfAhmvz48iBm0MTSSU3HYd8pM0="; # nix-prefetch-url "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/i915/mtl_huc_gsc.bin" | xargs nix hash to-sri --type sha256
          }} $out/lib/firmware/i915/mtl_huc_gsc.bin

          # GSC (Graphics System Controller) firmware for Arrow Lake
          # Arrow Lake requires GSC version 102.0.10.1878 or newer (higher than Meteor Lake)
          # Without this, xe driver causes hard lockups and i915 may have stability issues
          # See: https://www.phoronix.com/news/Intel-Require-Newer-ARL-GSC
          rm -f $out/lib/firmware/i915/mtl_gsc_1.bin $out/lib/firmware/i915/mtl_gsc_1.bin.zst 2>/dev/null || true
          cp ${final.fetchurl {
            url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/i915/mtl_gsc_1.bin";
            sha256 = "sha256-Aejiuw6ukOO0RxcDuwTRvROttDNzSA+xC+bxAbh34PM="; # nix-prefetch-url "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/i915/mtl_gsc_1.bin" | xargs nix hash to-sri --type sha256
          }} $out/lib/firmware/i915/mtl_gsc_1.bin
        '';
      });
    })
  ];

  custom = {
    # set Kernel options
    kernel = {
      flavor = "cachyos";
      cachyos.variant = "latest";
      cachyos.target = "x86_64-v3";
    };

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
      "zfs" # ZFS root with encryption
      "nvme" # NVMe boot drive
      "xhci_pci" # USB 3.x controller
      "usbhid" # USB keyboard (backup for ZFS password entry)
    ];
    initrd.kernelModules = [
      # MEI modules for i915 HuC authentication and GSC firmware (hardware video accel)
      # Load before i915 so GSC is ready when i915 initializes
      "mei"
      "mei_me"
      "mei_gsc_proxy"
      "i915"
    ];
    blacklistedKernelModules = [
      # NVIDIA conflicts
      "nouveau" # prevent conflicts with nvidia driver
      "nvidiafb"
      "rivafb"

      # TUXEDO platform conflicts
      "uniwill_laptop" # prevent conflicts with tuxedo_keyboard and tuxedo_io
      "asus_wmi" # prevent conflicts with tuxedo_keyboard and tuxedo_io
      "eeepc_wmi" # gets autoloaded by WMI GUIDs; spams "Unknown symbol ... asus_wmi_*" if asus_wmi is blocked

      # Hardware-specific issues
      "spd5118" # causes resume errors: spd5118_resume returns -6

      # Intel GPU: use i915, not xe (saves 4.5MB RAM)
      "xe"

      # Not needed on Intel systems
      "qrtr" # Qualcomm IPC Router - not needed on Intel

      # Legacy/unused ACPI modules
      "acpi_pad" # legacy processor aggregator - not needed on modern Intel

      # Unused subsystems
      "mac_hid" # HID emulation for non-HID devices - not needed
      "intel_vpu" # Arrow Lake NPU - not using AI acceleration
      "snd_seq_dummy" # ALSA sequencer dummy - not doing MIDI
      "autofs4" # automounting - not using autofs service
      "dmi_sysfs" # DMI sysfs interface - not needed

      # Input: legacy emulation (optional)
      "joydev" # joystick/gamepad events via /dev/input/js*
      "mousedev" # PS/2 mouse emulation via /dev/input/mouse*

      # CPU thermal: aggressive idle injection (optional)
      "intel_powerclamp"

      # Device mapper: not needed (using ZFS, not LVM/LUKS)
      "dm_mod"
    ];
    kernelModules = [
      "kvm-intel"
      "msr" # /dev/cpu/CPUNUM/msr provides an interface to read and write the model-specific registers (MSRs) of an x86 CPU
      "intel_rapl_msr" # help UCCD see TDP hardware
      "tuxedo_keyboard"
      "tuxedo_io"
    ];
    extraModulePackages = with config.boot.kernelPackages; [
      tuxedo-drivers # TUXEDO-specific drivers
      # r8125 removed - r8169 (in-kernel) works fine for RTL8125 2.5GbE
    ];

    # TUXEDO-specific: kernel parameters
    kernelParams = [
      # ACPI / keyboard
      "acpi_enforce_resources=lax" # Allow legacy driver access to ACPI resources; fixes non-compliant SW_LID implementations on some laptops

      # Modern standby / suspend
      "mem_sleep_default=s2idle" # Use s2idle (a.k.a. S0ix / modern standby) instead of deep (S3); Core Ultra CPUs don’t support S3
      # See: https://www.tuxedocomputers.com/en/Power-management-with-suspend-for-current-hardware.tuxedo

      # Intel Xe / i915 binding for Meteor Lake / Arrow Lake
      #"i915.force_probe=!7d67" # Prevent old i915 driver from binding this GPU
      #"xe.force_probe=7d67" # Force the new xe driver to bind the Meteor Lake device (PCI ID 7d67)

      # Intel i915 params:
      "i915.enable_fbc=0"
      "i915.enable_psr=0"
      "i915.enable_dc=0"
      "i915.enable_sagv=0" # Disable SAGV (System Agent voltage/frequency scaling) for stability
      "i915.enable_dmc_wl=1" # Prevent the Display Microcontroller from entering low-power state during display operations. May help with the PHY A refclk errors.
      "i915.enable_panel_replay=0" # Disable Panel Replay / PSR2 selective fetch. Some panels/firmware combos misbehave here. Can cause flicker or timing issues.
      "i915.enable_psr2_sel_fetch=0" # Disable PSR2 selective fetch. Some panels/firmware combos misbehave here. Can cause flicker or timing issues.

      # Intel i915: Load GuC + HuC
      "i915.enable_guc=3"

      # Kernel log buffer (2MB is enough for reduced logging)
      "log_buf_len=2M"

      # Intel Hybrid Performance: Enable 'active' mode to use Hardware P-States (HWP).
      # This offloads frequency scaling to the CPU's internal Thread Director for 
      # microsecond-fast P/E-core switching. Userspace (UCCD) now influences behavior 
      # via Energy Performance Preference (EPP) hints rather than direct scaling.
      "intel_pstate=active"

      # Select full kernel preemption via PREEMPT_DYNAMIC: lets higher‑prio tasks preempt most kernel code -> lower latency/better interactivity, small throughput/overhead cost.
      "preempt=full"

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

      # Boot / quiet
      "quiet"
      "splash"

      # Watchdog: enabled for detecting hard lockups (Intel iTCO watchdog)
      # NMI watchdog fires on hard CPU lockups; iTCO_wdt handles system-wide hangs
      # Watchdog timeout is configured via systemd-watchdog (default 10s)

      # Security mitigations off for performance (use only on trusted single-user systems)
      "mitigations=off"

      # Enable SysRq key for debugging/recovery
      "sysrq_always_enabled=1"

      # Disable audit subsystem
      "audit=0"

      # Classic network interface naming (eth0, wlan0)
      "net.ifnames=0"
      "biosdevname=0"

      # Timer/clock optimizations
      #"tsc=reliable"
      #"clocksource=tsc"

      # Workqueue: disable power-efficient mode for lower latency
      #"workqueue.power_efficient=0"

      # RCU: expedited grace periods for faster synchronization
      #"rcupdate.rcu_expedited=1"
    ];

    # --- extra kernel module options (goes into /etc/modprobe.d/nixos.conf) ---#
    # Keep this minimal: ONLY 'options' lines and no stray prose (avoid multi-line comment blocks that might confuse parsing).
    extraModprobeConfig = ''
      # Virtualization
      options kvm_intel nested=1

      # Wi-Fi / power
      options iwlmvm power_scheme=1
      options iwlwifi power_save=0 uapsd_disable=1

      # i915: ensure MEI is up before i915 tries to authenticate HuC via GSC
      softdep i915 pre: mei mei_me mei_gsc_proxy

      # TUXEDO keyboard module: set these as module options (NOT kernel cmdline)
      options tuxedo_keyboard kbd_backlight_mode=0

      # asus_wmi is being autoloaded via a WMI GUID match from the ACPI tables. Prevent it from loading.
      # Note: /bin/true doesn't exist in NixOS, use /run/current-system/sw/bin/true
      install asus_wmi /run/current-system/sw/bin/true
      install eeepc_wmi /run/current-system/sw/bin/true

      # ZFS ARC tuning for 96GB RAM
      # Cap ARC at 16GB to leave ~80GB for apps/games (default would use ~48GB)
      options zfs zfs_arc_max=17179869184
    '';
  };

  hardware = {
    # enable firmware with a license allowing redistribution
    enableRedistributableFirmware = lib.mkForce true;

    # enable all firmware regardless of license
    enableAllFirmware = lib.mkForce true;

    # Firmware is overridden via nixpkgs.overlays at the top of this file
    # This ensures enableAllFirmware uses our patched linux-firmware with correct GuC version

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
      # Important: disable tuxedo-rs and tailor-gui to avoid conflict with tuxedo-drivers and ucc
      enable = lib.mkForce false;
      tailor-gui.enable = lib.mkForce false; # GUI for TUXEDO Control Center equivalent
    };
  };

  # Use Wayland SDDM with kwin_wayland compositor
  # X11 mode has NixOS module bugs (empty CompositorCommand causes sddm-helper-start-wayland crash)
  # Force Intel GPU for the greeter to avoid NVIDIA issues
  services.displayManager.sddm.wayland.enable = lib.mkForce true;

  # SDDM X11 mode requires xserver to be enabled
  # Use Intel iGPU only for X11 - NVIDIA nouveau is blacklisted so modesetting fails on dGPU
  #services.xserver.enable = true;
  #services.xserver.deviceSection = ''
  #  BusID "PCI:0:2:0"
  #'';

  # Prevent X from auto-adding the NVIDIA GPU as a secondary screen
  # Without this, modesetting auto-probes nvidia-drm and fails because glamor
  # tries to use Mesa's nouveau driver which doesn't work with nvidia kernel module
  #services.xserver.serverFlagsSection = ''
  #  Option "AutoAddGPU" "false"
  #'';

  # Systemd hardware watchdog: automatically reboot on hard lockups
  # Intel iTCO watchdog will reset the system if systemd fails to ping it
  /*systemd.settings.Manager = {
    # Hardware watchdog timeout (seconds) - system reboots if no ping within this time
    RuntimeWatchdogSec = "30";
    # Reboot watchdog - ensure clean reboot completes within this time
    RebootWatchdogSec = "10min";
    # Shutdown watchdog - ensure clean shutdown completes within this time
    ShutdownWatchdogSec = "10min";
  };*/

  # Enable Uniwill Control Center
  # https://github.com/nanomatters/ucc
  services.uccd = {
    enable = true;
  };

  # Fix UCCD PrepareForSleep signal failure: ensure D-Bus is ready before UCCD starts
  systemd.services.uccd = {
    after = [ "dbus.service" ];
    wants = [ "dbus.service" ];
  };

  # Fix TCC service missing commands
  #systemd.services.tccd = {
  # Add missing utilities to PATH for TCC to work properly
  #  path = with pkgs; [
  #    toybox # provides 'users', 'cat', etc.
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

  # Disable OS prober - single-boot system, saves ~1-2s loader time
  boot.loader.grub.useOSProber = lib.mkForce false;
  boot.loader.timeout = lib.mkForce 1;

  services.xserver = {
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

  # Disable VirtualBox service to avoid hardware related stability issues
  virtualisation.virtualbox.host.enable = lib.mkForce false;
  virtualisation.virtualbox.host.enableExtensionPack = lib.mkForce false;

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Force intel-media-driver; Quick Sync decode/encode
    VDPAU_DRIVER = "va_gl"; # Forces Intel via VAAPI; VDPAU → VAAPI fallback
    MESA_LOADER_DRIVER_OVERRIDE = "iris"; # Xe OpenGL/Vulkan (not anv; iris=Gen12+)
    __GLX_VENDOR_LIBRARY_NAME = "mesa"; # Mesa GLX (avoid Nouveau/NVIDIA proprietary)
    ANV_ENABLE_PIPELINE_CACHE = "1"; # Enable Vulkan pipeline caching; Vulkan cache speedup
    # NIXOS_OZONE_WL is set system-wide in nixos/modules/kde.nix
    # mesa_glthread = "true"; # Disabled: causes KWin CPU spikes with Intel Xe driver
    # Don't set PRIME/NVIDIA variables globally - let apps default to Intel
    # Steam and other apps can override these as needed

    # Suppress MESA "experimental with Xe KMD" warning (expected for Arrow Lake)
    MESA_LOG_LEVEL = "error";

    # KWin Wayland fixes for Intel Xe (Arrow Lake)
    # https://bugs.kde.org/show_bug.cgi?id=513296
    # Increase safety margin to give Xe driver more time for atomic commits (default 1000µs)
    # Higher value = more latency but fewer "Device or resource busy" errors
    #KWIN_DRM_OVERRIDE_SAFETY_MARGIN = "3000";
    # NOTE: QT_LOGGING_RULES doesn't work here because kwin_wayland starts before session
    # variables are loaded. Use environment.etc."xdg/QtProject/qtlogging.ini" instead (below).
    #KWIN_DRM_NO_AMS = "1"; # Disable Atomic Mode Setting entirely; DISABLED: causes slow kwin rendering
    # Force software cursor to avoid hardware cursor plane atomic commits
    #KWIN_FORCE_SW_CURSOR = "1";
    # NOTE: KWIN_DRM_DEVICES is ':'-separated; don't use /dev/dri/by-path/* (they contain ':' in the PCI address).
    # Intel iGPU (0000:00:02.0) first, NVIDIA dGPU (0000:02:00.0) second.
    #KWIN_DRM_DEVICES = "/dev/dri/card-intel:/dev/dri/card-nvidia";
  };

  # Suppress KWin DRM warnings via Qt logging config file
  # This is more reliable than QT_LOGGING_RULES env var because kwin_wayland starts
  # before session variables are loaded (SDDM starts it as the Wayland compositor)
  # The "atomic commit failed: Device or resource busy" warnings are non-fatal retries
  # that succeed on retry - normal behavior at 300Hz where timing is tight (3.3ms/frame)
  environment.etc."xdg/QtProject/qtlogging.ini".text = ''
    [Rules]
    kwin_drm.warning=false
  '';

  # HiDPI fixes => https://github.com/NixOS/nixos-hardware/blob/3f7d0bca003eac1a1a7f4659bbab9c8f8c2a0958/common/hidpi.nix
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
  console.earlySetup = lib.mkDefault true;

  # Host-specific udev rules for NVMe optimization
  services.udev.extraRules = lib.mkAfter ''
    # Tell ModemManager to ignore WiFi interfaces (fixes "Missing port probe" warnings)
    ACTION=="add|change", SUBSYSTEM=="net", KERNEL=="wlan*", ENV{ID_MM_DEVICE_IGNORE}="1"

    # Disable Thunderbolt wakeup to prevent spurious S0ix wakes (GPE46)
    # TB4 USB Controller and NHI
    ACTION=="add|change", SUBSYSTEM=="pci", KERNEL=="0000:00:0d.0", ATTR{power/wakeup}="disabled"
    ACTION=="add|change", SUBSYSTEM=="pci", KERNEL=="0000:00:0d.2", ATTR{power/wakeup}="disabled"
    # TB4 PCIe Root Ports
    ACTION=="add|change", SUBSYSTEM=="pci", KERNEL=="0000:00:07.0", ATTR{power/wakeup}="disabled"
    ACTION=="add|change", SUBSYSTEM=="pci", KERNEL=="0000:00:07.1", ATTR{power/wakeup}="disabled"

    # Stable DRM symlinks for KWin/SDDM Wayland (avoid ':' in names; KWIN_DRM_DEVICES uses ':' as a separator)
    SUBSYSTEM=="drm", KERNEL=="card*", KERNELS=="0000:00:02.0", SYMLINK+="dri/card-intel"
    SUBSYSTEM=="drm", KERNEL=="card*", KERNELS=="0000:02:00.0", SYMLINK+="dri/card-nvidia"
  '';

  # Dynamic KWIN_DRM_DEVICES: only add NVIDIA GPU when an external display is connected to it.
  # This avoids cross-GPU buffer sharing overhead and "atomic commit failed" log spam
  # when only the internal Intel display is in use.
  # Runs before plasma-kwin_wayland.service via systemd user environment.
  environment.etc."profile.d/kwin-gpu-detect.sh".text = ''
    # Detect if any NVIDIA-wired connector (HDMI/DP) has a display plugged in.
    # card0 = NVIDIA (0x10de), card1 = Intel (0x8086) on this machine.
    # Uses stable symlinks: /dev/dri/card-intel, /dev/dri/card-nvidia
    _nv_connected=0
    for _conn in /sys/class/drm/card0-*; do
      [ -f "$_conn/status" ] && [ "$(cat "$_conn/status" 2>/dev/null)" = "connected" ] && _nv_connected=1
    done

    if [ "$_nv_connected" = "1" ]; then
      export KWIN_DRM_DEVICES="/dev/dri/card-intel:/dev/dri/card-nvidia"
    else
      export KWIN_DRM_DEVICES="/dev/dri/card-intel"
    fi
    unset _nv_connected _conn
  '';

  # Also set it for the systemd user session so plasma-kwin_wayland.service picks it up.
  # profile.d scripts only run for login shells; KWin is launched by systemd, not a shell.
  systemd.user.services.kwin-gpu-detect = {
    description = "Detect NVIDIA external displays for KWin DRM device selection";
    wantedBy = [ "graphical-session-pre.target" ];
    before = [ "plasma-kwin_wayland.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "kwin-gpu-detect" ''
        nv_connected=0
        for conn in /sys/class/drm/card0-*; do
          if [ -f "$conn/status" ] && [ "$(cat "$conn/status" 2>/dev/null)" = "connected" ]; then
            nv_connected=1
            break
          fi
        done

        if [ "$nv_connected" = "1" ]; then
          ${pkgs.systemd}/bin/systemctl --user set-environment KWIN_DRM_DEVICES=/dev/dri/card-intel:/dev/dri/card-nvidia
        else
          ${pkgs.systemd}/bin/systemctl --user set-environment KWIN_DRM_DEVICES=/dev/dri/card-intel
        fi
      '';
    };
  };
}
