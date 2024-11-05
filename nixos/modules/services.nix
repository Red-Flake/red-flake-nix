{ config, lib, pkgs, modulesPath, ... }:

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

  # Disable power-profiles-daemon (interferes with cpufreq)
  services.power-profiles-daemon.enable = false;

  # Postgresql settings
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    settings = {
        port = 5432;
    };
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
      host all all      ::1/128      trust
      host all postgres 127.0.0.1/32 trust
      host all msf 127.0.0.1/32 trust
    '';
    initialScript = pkgs.writeText "backend-initScript" ''
        CREATE ROLE msf WITH LOGIN PASSWORD 'msf' CREATEDB;
        CREATE DATABASE msf;
        GRANT ALL PRIVILEGES ON DATABASE msf TO msf;
    '';
  };

  # Neo4j settings
  services.neo4j = {
    enable = true;
    directories.home = lib.mkForce "/var/lib/neo4j";
    directories.imports = lib.mkForce "/var/lib/neo4j/import";
    directories.data = lib.mkForce "/var/lib/neo4j/data";
    directories.plugins = lib.mkForce "/var/lib/neo4j/plugins";
    directories.certificates = lib.mkForce "/var/lib/neo4j/certificates";
    https.sslPolicy = "legacy";
    http.listenAddress = ":7474";
    https.listenAddress = ":7473";
    bolt.tlsLevel = "DISABLED";
    bolt.sslPolicy = "legacy";
    bolt.listenAddress = ":7687";
    bolt.enable = true;
    https.enable = false;
  };

  # Fwupd settings
  services.fwupd = {
    enable = true;
  };

  # Pipewire settings
  # Disable Pulseaudio
  hardware.pulseaudio.enable = false;
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  # Enable Pipewire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # TRIM settings
  # Enable periodic TRIM
  services.fstrim.enable = true;

  # DBus settings
  # Enable DBus
  services.dbus.enable = true;
  # use dbus broker as the default implementation
  services.dbus.implementation = "broker";

  # Fix Intel CPU throttling
  services.throttled.enable = true;

  # Enable timesyncd
  services.timesyncd.enable = true;

  # Enable profile-sync-daemon
  services.psd.enable = true;
  services.psd.resyncTimer = "30min";

  # Enable Flatpak support
  services.flatpak.enable = true;

  # Enable Ananicy-Cpp with CachyOS rulesets
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
    settings = {
      apply_nice = true;
    };
  };

   # Make nixos boot slightly faster by turning these off during boot
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.services.systemd-udev-settle.enable = false;

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
