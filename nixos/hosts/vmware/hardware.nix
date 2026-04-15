_:
{

  custom = {
    # enable ZFS encryption
    zfs.encryption = true;

    # set display resolution to 1080p
    display.resolution = "1080p";
  };

  boot.kernelParams = [
    "quiet"
    "splash"
    "mitigations=off"
    "libahci.ignore_sss=1"
    "sysrq_always_enabled=1"
    "split_lock_detect=off"
    "audit=0"
    "net.ifnames=0"
    "biosdevname=0"
  ];

  # Enable vmware video driver for better performance
  services.xserver.videoDrivers = [ "vmware" ];

  # Enable VMWare guest tools
  virtualisation.vmware.guest.enable = true;

}
