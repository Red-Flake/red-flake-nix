{ config, lib, pkgs, modulesPath, ... }:

{
    powerManagement = {
        enable = true;
        cpuFreqGovernor = "performance";
    };
}