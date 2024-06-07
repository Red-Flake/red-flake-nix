{ config, lib, pkgs, modulesPath, ... }:

{
  # Enable Grub Bootloader
  boot.kernelParams = [ "i915.enable_fbc=1", "i915.fastboot=1", "fsck.mode=skip", "loglevel=0", "rd.systemd.show_status=false", "nowatchdog", "kernel.nmi_watchdog=0", "nomce", "mitigations=off", "libahci.ignore_sss=1", "modprobe.blacklist=iTCO_wdt", "modprobe.blacklist=sp5100_tco", "processor.ignore_ppc=1", "sysrq_always_enabled=1", "split_lock_detect=off", "consoleblank=0", "audit=0", "net.ifnames=0", "biosdevname=0" ];
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    grub = {
      efiSupport = true;
      device = "nodev";
    };
  };
}
