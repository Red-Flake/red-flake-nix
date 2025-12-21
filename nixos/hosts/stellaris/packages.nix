{ config
, lib
, pkgs
, inputs
, ...
}:
{
  environment.systemPackages = with pkgs; [
    linuxKernel.packages.linux_xanmod_latest.turbostat
    s0ix-selftest-tool
    intel-gpu-tools
  ];
}
