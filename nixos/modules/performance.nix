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

    # Enable scx_bpfland scheduler
    services.scx = {
      enable = true;
      scheduler = "scx_bpfland";
      # Optional: Set extra options for the scheduler
      extraArgs = [
        "--lowlatency"  # Optional: For better responsiveness under load
      ];
    };
}