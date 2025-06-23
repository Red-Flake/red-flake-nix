{ 
  config,
  lib,
  pkgs,
  inputs,
  ... 
}: {

  custom = {
    # enable ZFS encryption
    zfs.encryption = true;
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
      "thinkpad_acpi"
      "msr"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [
      "kvm-intel"
      "msr"  # for undervolting Intel CPUs
    ];
    extraModulePackages = [ ];
    
    # Set extra kernel module options
    extraModprobeConfig = "options kvm_intel nested=1\noptions thinkpad_acpi fan_control=1 experimental=1\noptions i915 enable_dc=0";
  };

  hardware = {
    # enable firmware with a license allowing redistribution
    enableRedistributableFirmware = lib.mkForce true;

    # enable all firmware regardless of license
    enableAllFirmware = lib.mkForce true;

    # enable CPU microcode updates
    cpu.intel.updateMicrocode = lib.mkForce true;
  };

  services = {
    # Workaround for Intel throttling issues in Linux.
    throttled.enable = true;

    # ThinkFan settings
    thinkfan = {
      enable = true;

      # Use tpacpi to control the ThinkPad fan via ACPI
      fans = [ { type = "tpacpi"; query = "/proc/acpi/ibm/fan"; } ];

      # "extraArgs" lets you pass any CLI flags (e.g. -s <seconds>) directly
      # to the thinkfan binary.
      # Here, we slow polling down to 10 s instead of 5 s. Poll more slowly to reduce "hunting" around a boundary:
      extraArgs = [ "-s" "10" ];

      # Adjust thresholds for quieter operation:
      levels = [
        # LEVEL MIN_TEMP  MAX_TEMP
        [ 0      0          60   ]   # fan off until cores reach ~60 °C
        [ 1     59          65   ]   # 59–65 °C: very low-speed fan
        [ 2     64          70   ]   # 64–70 °C: low RPM
        [ 3     69          75   ]   # 69–75 °C: medium RPM
        [ 4     74          80   ]   # 74–80 °C: moderately silent but spinning
        [ 5     79          85   ]   # 79–85 °C: medium-high RPM
        [ 6     84          90   ]   # 84–90 °C: high RPM
        [ "level full-speed" 89  32767 ] # ≥ 89 °C: full blast
      ];

      # Monitor all three CPU cores via coretemp.
      sensors = [
        { type = "hwmon"; 
          query = "/sys/devices/platform/coretemp.0/hwmon/"; 
          indices = [ 1 2 3 4 5 ];  # usually coretemp exposes temp1_input, temp2_input, temp3_input, etc.
        }
      ];
    };

  };

  environment.systemPackages = with pkgs; [
    intel-compute-runtime
  ];

}
