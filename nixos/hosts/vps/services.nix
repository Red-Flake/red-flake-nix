{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  # ZFS services
  services.zfs = {
    ## Enable Autoscrub
    autoScrub = {
      enable = true;
      pools = [ "zroot" ];
    };

    ## Enable automated snapshots
    autoSnapshot.enable = true;

    ## Enable TRIM
    trim.enable = true;
  };

  # https://github.com/openzfs/zfs/issues/10891
  systemd.services.systemd-udev-settle.enable = false;
  # snapshot dirs sometimes not accessible
  # https://github.com/NixOS/nixpkgs/issues/257505#issuecomment-2348313665
  systemd.services.zfs-mount = {
    serviceConfig = {
      ExecStart = [ "${lib.getExe' pkgs.util-linux "mount"} -t zfs zroot/persist -o remount" ];
    };
  };

  # Disable power-profiles-daemon (interferes with cpufreq)
  services.power-profiles-daemon.enable = false;

  # Fwupd settings
  services.fwupd = {
    enable = true;
  };

  # TRIM settings
  # Enable periodic TRIM
  services.fstrim.enable = true;

  # Enable timesyncd
  services.timesyncd.enable = true;

  # Schedulers from https://wiki.archlinux.org/title/improving_performance
  services.udev.extraRules = ''
    # Needed for ZFS. Otherwise the system can freeze
    ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
    # HDD
    ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
    # SSD
    ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"
    # NVMe SSD
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
  '';

}
