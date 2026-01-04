{ lib
, ...
}:
{

  swapDevices = [
    {
      device = "/dev/disk/by-label/SWAP";
      priority = 1; # Ensure ZRAM (priority 100) is used first
    }
  ];

  fileSystems = {

    # root on tmpfs
    # neededForBoot is required, so there won't be permission errors creating directories or symlinks
    # https://github.com/nix-community/impermanence/issues/149#issuecomment-1806604102
    "/" = lib.mkForce {
      device = "tmpfs";
      fsType = "tmpfs";
      neededForBoot = true;
      options = [
        "defaults"
        "size=1G"
        "mode=755"
      ];
    };

    # /boot is mounted read-write initially, then remounted read-only after boot
    # by the boot-readonly systemd service. This prevents corruption during forced shutdowns.
    # Use `nixos-rebuild-safe` wrapper script for rebuilds (handles remounting).
    "/boot" = {
      device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };

    "/home" = {
      device = "zroot/home";
      fsType = "zfs";
    };

    "/nix" = {
      device = "zroot/nix";
      fsType = "zfs";
    };

    # by default, /tmp is not a tmpfs on nixos as some build artifacts can be stored there
    # when using / as a small tmpfs for impermanence, /tmp can then easily run out of space,
    # so create a dataset for /tmp to prevent this
    # /tmp is cleared on boot via `boot.tmp.cleanOnBoot = true;`
    "/tmp" = {
      device = "zroot/tmp";
      fsType = "zfs";
    };

    "/persist" = {
      device = "zroot/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/cache" = {
      device = "zroot/cache";
      fsType = "zfs";
      neededForBoot = true;
    };

  };

  # let /cache be world writable
  systemd.tmpfiles.rules = [
    "d /cache 0777 root root -"
  ];

  # https://github.com/openzfs/zfs/issues/10891
  systemd.services.systemd-udev-settle.enable = false;

  # https://github.com/NixOS/nixpkgs/issues/257505
  #custom.shell.packages.remount-persist = ''
  #  sudo mount -t zfs zroot/persist -o remount
  #'';

}
