{ config
, lib
, pkgs
, user
, inputs
, ...
}:

let
  hostType = config.custom.hostType or "security";
  isSecurityHost = hostType == "security";
  isDesktopHost =
    builtins.elem hostType [
      "security"
      "desktop"
    ];

  # We need to use the Neo4j LTS version 4.4.11 because In Neo4j 5.x the legacy procedure CALL db.indexes() was removed (replaced by SHOW INDEXES). BloodHound CE 8 still calls db.indexes, so it expects Neo4j 4.4.x.
  # See: https://github.com/SpecterOps/BloodHound/blob/03454913830fec12eebc4451dca8af8b3b3c44d7/tools/docker-compose/neo4j.Dockerfile#L17
  neo4j_4_4_11 = inputs.nixpkgs-neo4j-4-4-11.legacyPackages.${pkgs.stdenv.hostPlatform.system}.neo4j;

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

    ## Periodic full-pool TRIM: disabled on purpose.
    ##
    ## install.sh creates zroot with `-o autotrim=on`, so freed blocks are
    ## trimmed continuously as they are released. The weekly zpool-trim.timer
    ## would additionally re-trim the *entire* free space on top of that.
    ##
    ## That redundant pass saturates the device: on stellaris it was measured at
    ## 9.8s of IO stall per 10s wall-clock (/proc/pressure/io "full") for its
    ## whole duration, which shows up as desktop stickiness.
    ##
    ## Re-enable this only for a pool created without autotrim:
    ##   zpool get autotrim <pool>
    trim.enable = false;

    ## ZED (ZFS Event Daemon) configuration
    ## Disable LED scripts that cause "Failed to stat" errors on systems without enclosure LEDs
    zed.settings = {
      # Disable LED-related scripts (not needed without drive enclosure LED support)
      ZED_USE_ENCLOSURE_LEDS = false;
    };
    zed.enableMail = false; # Disable email notifications (requires mail setup)
  };

  # Only run daily ZFS snapshots (disable other intervals)
  systemd.timers."zfs-snapshot-frequent".enable = false;
  systemd.timers."zfs-snapshot-hourly".enable = false;
  systemd.timers."zfs-snapshot-weekly".enable = false;
  systemd.timers."zfs-snapshot-monthly".enable = false;

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
  # Used by BloodHound CE. Metasploit uses its own embedded PostgreSQL via msfdb.
  services.postgresql = lib.mkIf isSecurityHost {
    enable = lib.mkDefault true;

    # set PostgreSQL Version to 18
    package = pkgs.postgresql_18;
    enableTCPIP = true;
    settings.port = 5432;
    authentication = lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
      host all all      ::1/128      trust
      host all postgres 127.0.0.1/32 trust
      host all bloodhound 127.0.0.1/32 trust
    '';
    # Note: initialScript only runs on first DB cluster creation.
    # postgresql-ensure-users.service handles ongoing permission fixes for PostgreSQL 15+.
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE ROLE bloodhound WITH LOGIN PASSWORD 'bloodhound' CREATEDB;
      CREATE DATABASE bloodhound;
      GRANT ALL PRIVILEGES ON DATABASE bloodhound TO bloodhound;
    '';
  };

  # Ensure PostgreSQL users have proper permissions (PostgreSQL 15+ compatibility)
  # This runs on every boot to fix permissions that initialScript misses
  systemd.services.postgresql-ensure-users = lib.mkIf isSecurityHost {
    description = "Ensure PostgreSQL users have proper schema permissions";
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ config.services.postgresql.package ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      RemainAfterExit = true;
    };
    script = ''
      # Ensure bloodhound database and permissions (PostgreSQL 15+ requires explicit schema grants)
      psql -d postgres <<-'EOSQL'
        DO $$
        BEGIN
          IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'bloodhound') THEN
            CREATE ROLE bloodhound WITH LOGIN PASSWORD 'bloodhound' CREATEDB;
          END IF;
          IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'bloodhound') THEN
            CREATE DATABASE bloodhound OWNER bloodhound;
          END IF;
        END $$;
      EOSQL

      psql -d bloodhound -c "ALTER DATABASE bloodhound OWNER TO bloodhound;"
      psql -d bloodhound -c "GRANT ALL ON SCHEMA public TO bloodhound;"
    '';
  };

  # Neo4j settings
  services.neo4j = lib.mkIf isSecurityHost {
    enable = lib.mkDefault true;

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
  systemd.services.neo4j.preStart = lib.mkIf isSecurityHost (lib.mkForce ''
    set -eu
    install -d -m 0700 -o neo4j -g neo4j /var/lib/neo4j/{conf,logs,run,plugins,import,data}
    install -m 0600 -o neo4j -g neo4j ${neo4j44Conf} /var/lib/neo4j/conf/neo4j.conf
  '');

  # BloodHound-CE service settings
  services.bloodhound-ce = lib.mkIf isSecurityHost {
    enable = lib.mkDefault true;
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

      featureFlags.darkMode = true;
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
  # Fwupd (desktop/laptop only by default)
  services.fwupd.enable = lib.mkDefault isDesktopHost;

  # Pipewire settings
  # Disable Pulseaudio
  # Audio stack (desktop only by default)
  services.pulseaudio.enable = lib.mkIf isDesktopHost false;
  # rtkit is optional but recommended
  security.rtkit.enable = lib.mkDefault isDesktopHost;
  # Enable Pipewire
  services.pipewire = lib.mkIf isDesktopHost {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # TRIM settings
  # Note: For ZFS, use services.zfs.trim.enable (set above) instead of fstrim.
  # fstrim doesn't work on ZFS mountpoints - ZFS handles TRIM internally.
  # Disable fstrim timer since we use ZFS (which has its own zpool-trim.timer)
  services.fstrim.enable = false;

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
  # Enable profile-sync-daemon (desktop only by default)
  services.psd = lib.mkIf isDesktopHost {
    enable = true;
    resyncTimer = "30min";
  };

  # Fix race condition between PSD and Home Manager
  # Ensure Home Manager completes before PSD starts
  systemd.user.services.psd = lib.mkIf isDesktopHost {
    wants = [ "home-manager-${user}.service" ];
    after = [ "home-manager-${user}.service" ];
  };

  # Disable speech-dispatcher socket (TTS accessibility service not needed)
  # Prevents failed service errors from socket activation
  # Disable speech-dispatcher socket (desktop only; prevents failed activation noise)
  systemd.user.sockets.speech-dispatcher.enable = lib.mkIf isDesktopHost false;

  # Enable Flatpak support
  # Flatpak (desktop only by default)
  services.flatpak.enable = lib.mkDefault isDesktopHost;

  # Make nixos boot slightly faster by turning these off during boot
  systemd.services.NetworkManager-wait-online.enable = false;

  # =============================================================================
  # Disabled services - to re-enable, remove or comment out the corresponding line
  # =============================================================================

  # Note: acpid is kept enabled - NVIDIA driver uses it for battery/power events on laptops
  # Note: nscd cannot be disabled - required for systemd NSS modules (DynamicUser services)

  # Disable ModemManager: Manages mobile broadband (3G/4G/LTE) modems and SMS
  # Used by: USB mobile broadband dongles, some phones in modem mode
  # Re-enable if: You need to use a USB cellular modem for internet
  # Note: NetworkManager pulls this in by default, we explicitly disable it
  systemd.services.ModemManager.enable = false;

  # Schedulers from https://wiki.archlinux.org/title/improving_performance
  # NVMe scheduler is set in base.nix; only need HDD/SSD rules here
  services.udev.extraRules = ''
    # ZFS partitions on SATA: disable scheduler (ZFS has its own I/O pipeline)
    ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
    # HDD
    ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
    # SSD (SATA)
    ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"

    # VPN split tunneling: trigger service when tun interface is created
    ACTION=="add", KERNEL=="tun[0-9]*", TAG+="systemd", ENV{SYSTEMD_WANTS}+="vpn-split-tunnel@%k.service"
  '';

  # VPN split tunneling service - fixes source IP issues for lab VPNs
  # Problem: When VPN is connected, some apps send packets with VPN source IP out wlan0.
  # Remote servers can't reply because the VPN IP is unreachable from the internet.
  # Solution: Add SNAT/masquerade rule to rewrite source IP for non-VPN traffic.
  systemd.services."vpn-split-tunnel@" = {
    description = "Enable split tunneling for VPN interface %i";
    after = [ "sys-devices-virtual-net-%i.device" ];
    path = [ pkgs.iproute2 pkgs.iptables pkgs.gawk pkgs.coreutils ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
    };
    script = ''
      INTERFACE="%i"

      # Wait for OpenVPN to configure the interface
      sleep 2

      # Get the VPN interface's IP address
      VPN_IP=$(ip -4 addr show dev "$INTERFACE" 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)

      if [ -n "$VPN_IP" ]; then
        # Add masquerade rule: traffic from VPN IP going out non-tun interfaces
        # gets its source IP rewritten to the outgoing interface's IP
        if ! iptables -t nat -C POSTROUTING -s "$VPN_IP" ! -o "$INTERFACE" -j MASQUERADE 2>/dev/null; then
          iptables -t nat -A POSTROUTING -s "$VPN_IP" ! -o "$INTERFACE" -j MASQUERADE
          echo "VPN NAT enabled: masquerading traffic from $VPN_IP on non-VPN interfaces"
        else
          echo "VPN NAT rule already exists for $VPN_IP"
        fi
      else
        echo "Could not determine IP for $INTERFACE"
      fi
    '';
  };

}
