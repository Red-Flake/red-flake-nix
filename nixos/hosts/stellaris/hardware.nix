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
      "nvidiafb"
      "rivafb"
      "spd5118" # blacklist to avoid these issues: [  146.522972] spd5118 14-0050: Failed to write b = 0: -6    [  146.522974] spd5118 14-0050: PM: dpm_run_callback(): spd5118_resume [spd5118] returns -6     [  146.522978] spd5118 14-0050: PM: failed to resume async: error -6
      "tuxedo_nb02_nvidia_power_ctrl" # blacklist to avoid conflict with nvidia module; the tuxedo module cannot control the power state
    ];
    kernelModules = [
      "xe" # load Intel Xe Graphics kernel module
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
      "xe.force_probe=7d67" # Force the new xe driver to bind the Meteor Lake device (PCI ID 7d67)
      "i915.force_probe=!7d67" # Prevent old i915 driver from binding this GPU

      # --- Intel GPU (legacy workarounds; can still matter if other outputs fallback to i915) ---
      "i915.enable_psr=0" # Disable Panel Self Refresh (PSR); avoids "PHY A failed to request refclk" timing bug
      "i915.enable_dc=0" # Disable Display C-states (deep idle); avoids the same refclk bug
    ];

    # --- extra kernel module options (goes into /etc/modprobe.d/nixos.conf) ---#
    # Keep this minimal: ONLY 'options' lines and no stray prose (avoid multi-line comment blocks that might confuse parsing).
    extraModprobeConfig = ''
      # Virtualization
      options kvm_intel nested=1

      # Wi-Fi / power
      options iwlmvm power_scheme=1
      options iwlwifi power_save=0 uapsd_disable=1

      # Intel GPU: enable GuC/HuC firmware loading (needed for newer platforms)
      options i915 enable_guc=3

      # TUXEDO keyboard module: set these as module options (NOT kernel cmdline)
      options tuxedo_keyboard kbd_backlight_mode=0
      options tuxedo_keyboard kbd_backlight_brightness=255
      options tuxedo_keyboard kbd_backlight_color_left=0x0000ff
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
        libvdpau-va-gl # VDPAU driver with OpenGL/VAAPI backend
        vpl-gpu-rt # For Intel QSV (Quick Sync Video)
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        libvdpau-va-gl # VDPAU driver with OpenGL/VAAPI backend
      ];
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

  # Enable Intel driver in XServer
  services.xserver.videoDrivers = [
    "modesetting"
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
