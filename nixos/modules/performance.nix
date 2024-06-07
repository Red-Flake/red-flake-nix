{ config, lib, pkgs, modulesPath, ... }:

{
    powerManagement.cpuFreqGovernor = "performance";
}