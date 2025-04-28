{ config, lib, pkgs, modulesPath, ... }:

{
    powerManagement = {
        enable = lib.mkForce true;
        cpuFreqGovernor = lib.mkDefault "performance";
        powertop.enable = lib.mkForce false;
    };

    services.tlp = {
      enable = lib.mkForce false;
    };
}