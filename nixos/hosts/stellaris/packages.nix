{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    envycontrol
    linuxKernel.packages.linux_xanmod_latest.turbostat
  ];
}
