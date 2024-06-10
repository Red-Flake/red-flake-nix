{ config, lib, pkgs, modulesPath, ... }:

{
  # Disable power-profiles-daemon (interferes with cpufreq)
  services.power-profiles-daemon.enable = false;

  # OpenSSH settings
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

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
    directories.home = "/var/lib/neo4j";
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
  # Remove sound.enable or set it to false if you had it set previously, as sound.enable is only meant for ALSA-based configurations
  # rtkit is optional but recommended
  security.rtkit.enable = true;
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

  # Fix Intel CPU throttling
  services.throttled.enable = true;

  # Enable timesyncd
  services.timesyncd.enable = true;

}