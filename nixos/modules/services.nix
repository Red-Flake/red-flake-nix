{
  config,
  lib,
  pkgs,
  modulesPath,
  user,
  ...
}:

let
  # We need to use the Neo4j LTS version 4.4.11 because In Neo4j 5.x the legacy procedure CALL db.indexes() was removed (replaced by SHOW INDEXES). BloodHound CE 8 still calls db.indexes, so it expects Neo4j 4.4.x.
  # See: https://github.com/SpecterOps/BloodHound/blob/03454913830fec12eebc4451dca8af8b3b3c44d7/tools/docker-compose/neo4j.Dockerfile#L17
  # Neo4j 4.4.11 is the latest Neo4j build available through https://lazamar.co.uk/nix-versions/
  # get sha256 from rev using: `nix-prefetch-git https://github.com/NixOS/nixpkgs/ 7a339d87931bba829f68e94621536cad9132971a`
  # https://lazamar.co.uk/nix-versions/?package=neo4j&version=4.4.11&fullName=neo4j-4.4.11&keyName=neo4j&revision=7a339d87931bba829f68e94621536cad9132971a&channel=nixpkgs-unstable#instructions
  revpkgs =
    import
      (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/7a339d87931bba829f68e94621536cad9132971a.tar.gz";
        sha256 = "1w4zyrdq7zjrq2g3m7bhnf80ma988g87m7912n956md8fn3ybhr4";
      })
      {
        system = "x86_64-linux"; # Set your system explicitly
      };

  neo4j_4_4_11 = revpkgs.neo4j;

  # also add neo4j settings from https://github.com/SpecterOps/BloodHound/blob/03454913830fec12eebc4451dca8af8b3b3c44d7/tools/docker-compose/neo4j.Dockerfile#L17
  neo4j44Conf = pkgs.writeText "neo4j-4.4.conf" ''
    # Neo4j 4.4 style config (no server.* keys)

    # Listen on localhost (or 0.0.0.0 if you prefer)
    dbms.default_listen_address=127.0.0.1

    # Bolt
    dbms.connector.bolt.enabled=true
    dbms.connector.bolt.listen_address=:7687
    dbms.connector.bolt.tls_level=DISABLED

    # HTTP
    dbms.connector.http.enabled=true
    dbms.connector.http.listen_address=:7474

    # (optional) HTTPS
    # dbms.connector.https.enabled=false
    # dbms.connector.https.listen_address=:7473

    # GDS permissions
    dbms.security.procedures.unrestricted=gds.*
    dbms.security.procedures.allowlist=gds.*

    # from https://github.com/SpecterOps/BloodHound/blob/03454913830fec12eebc4451dca8af8b3b3c44d7/tools/docker-compose/neo4j.Dockerfile#L17
    dbms.security.auth_enabled=false
    dbms.security.procedures.unrestricted=apoc.periodic.*,*.specterops.*
    dbms.security.procedures.allowlist=apoc.periodic.*,*.specterops.*

    # Logs/data/run live under /var/lib/neo4j
  '';
in
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
      host all bloodhound 127.0.0.1/32 trust
    '';
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE ROLE msf WITH LOGIN PASSWORD 'msf' CREATEDB;
      CREATE DATABASE msf;
      GRANT ALL PRIVILEGES ON DATABASE msf TO msf;

      CREATE ROLE bloodhound WITH LOGIN PASSWORD 'bloodhound' CREATEDB;
      CREATE DATABASE bloodhound;
      GRANT ALL PRIVILEGES ON DATABASE bloodhound TO bloodhound;
    '';
  };

  # Neo4j settings
  services.neo4j = {
    enable = true;

    # set package to 4.4.11 for BloodHound CE compatibility
    package = neo4j_4_4_11;

    # set neo4j directories to /var/lib/neo4j
    directories.home = lib.mkForce "/var/lib/neo4j";
    directories.data = lib.mkForce "/var/lib/neo4j/data";
    directories.plugins = lib.mkForce "/var/lib/neo4j/plugins";
    directories.imports = lib.mkForce "/var/lib/neo4j/import";
    directories.certificates = lib.mkForce "/var/lib/neo4j/certificates";

    # setup listeners
    https.sslPolicy = "legacy";
    http.listenAddress = ":7474";
    https.listenAddress = ":7473";
    bolt.tlsLevel = "DISABLED";
    bolt.sslPolicy = "legacy";
    bolt.listenAddress = ":7687";
    bolt.enable = true;
    https.enable = false;

    # IMPORTANT: use 4.4 keys and allow gds procedures
    extraServerConfig = ""; # we’re supplying the whole file ourselves
  };

  # Force our own preStart so the neo4j module does NOT link its generated server.* file.
  systemd.services.neo4j.preStart = lib.mkForce ''
    set -eu
    install -d -m 0700 -o neo4j -g neo4j /var/lib/neo4j/{conf,logs,run,plugins,import,data}
    install -m 0600 -o neo4j -g neo4j ${neo4j44Conf} /var/lib/neo4j/conf/neo4j.conf
  '';

  # BloodHound-CE service settings
  services.bloodhound-ce = {
    enable = true;
    package = pkgs.bloodhound-ce;
    openFirewall = true;
    # optional DB env if not using ident socket auth
    # database.passwordFile = "/run/secrets/bh-db.env"; # contains: PGPASSWORD=...
    settings = {
      server.host = "127.0.0.1";
      server.port = 9090;

      logLevel = "info";
      logPath = "/var/log/bloodhound-ce/bloodhound.log";

      defaultAdmin = {
        principalName = "admin";
        password = "Password1337";
        expireNow = false;
      };

      recreateDefaultAdmin = false;

      featureFlags = {
        darkMode = true;
      };
    };

    database = {
      host = "127.0.0.1";
      user = "bloodhound";
      name = "bloodhound";
      password = "bloodhound";
      # passwordFile = "/run/secrets/bh-db.env"; # bhe_database_secret=...
    };

    # We need to use the Neo4j LTS version 4.4.x because In Neo4j 5.x the legacy procedure CALL db.indexes() was removed (replaced by SHOW INDEXES). BloodHound CE 8 still calls db.indexes, so it expects Neo4j 4.4.x.
    # See: https://github.com/SpecterOps/BloodHound/blob/03454913830fec12eebc4451dca8af8b3b3c44d7/tools/docker-compose/neo4j.Dockerfile#L17
    neo4j = {
      host = "127.0.0.1";
      port = 7687;
      database = "neo4j";
      user = "neo4j";
      password = "Password1337";
      # passwordFile = "/run/secrets/bh-neo4j.env"; # bhe_neo4j_secret=...
    };
  };

  # Fwupd settings
  services.fwupd = {
    enable = true;
  };

  # Pipewire settings
  # Disable Pulseaudio
  services.pulseaudio.enable = false;
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
  services.dbus = {
    # Enable DBus
    enable = true;

    # use dbus broker as the default implementation
    implementation = "broker";
  };

  # Enable timesyncd
  services.timesyncd.enable = true;

  # Enable profile-sync-daemon
  services.psd = {
    enable = true;
    resyncTimer = "30min";
  };

  # Fix race condition between PSD and Home Manager
  # Ensure Home Manager completes before PSD starts
  systemd.user.services.psd = {
    wants = [ "home-manager-${user}.service" ];
    after = [ "home-manager-${user}.service" ];
  };

  # Enable Flatpak support
  services.flatpak.enable = true;

  # Disable Ananicy-Cpp (conflicts with scx schedulers)
  services.ananicy = {
    enable = false;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
    settings = {
      apply_nice = true;
    };
  };

  # Make nixos boot slightly faster by turning these off during boot
  systemd.services.NetworkManager-wait-online.enable = false;

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
    # Set queue depth for NVMe (helps with ZFS performance)
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/nr_requests}="256"
  '';

}
