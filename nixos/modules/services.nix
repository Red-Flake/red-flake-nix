{ config, lib, pkgs, modulesPath, ... }:

{
  # OpenSSH settings
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  # X11 / Wayland settings
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "plasma";
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.wayland.enable = true;

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

  services.neo4j = {
    enable = true;
  };

}