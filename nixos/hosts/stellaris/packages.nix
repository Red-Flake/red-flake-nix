{ inputs, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    linuxKernel.packages.linux_xanmod_latest.turbostat
    intel-gpu-tools
    inputs.redflake-packages.packages.x86_64-linux.outline-electron
  ];
}
