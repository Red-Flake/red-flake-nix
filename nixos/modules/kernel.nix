{ config, lib, pkgs, modulesPath, ... }:

{
  # Kernel Packages to install

  # Switch to latest linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
