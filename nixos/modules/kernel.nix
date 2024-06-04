{ config, lib, pkgs, modulesPath, ... }:

{
  # Kernel Packages to install
  boot.kernelPackages = with pkgs; [
    # Switch to latest linux kernel
    linuxPackages_latest
  ];
}
