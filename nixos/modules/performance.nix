{ config, lib, pkgs, modulesPath, ... }:

{
    powerManagement = {
        enable = true;
        cpuFreqGovernor = lib.mkDefault "performance";
        powertop.enable = true;
    };
}