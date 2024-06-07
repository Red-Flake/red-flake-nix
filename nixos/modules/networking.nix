{ config, lib, pkgs, modulesPath, ... }:

{
  networking.networkmanager.enable = true;
  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.hostName = "redflake";
}
