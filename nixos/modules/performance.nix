{ config, lib, pkgsx86_64_v3, modulesPath, ... }:

{
    powerManagement = {
        enable = true;
        cpuFreqGovernor = lib.mkDefault "performance";
        powertop.enable = true;
    };
}