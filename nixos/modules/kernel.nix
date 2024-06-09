{ config, lib, pkgs, modulesPath, ... }:

{
  # Kernel Packages to install

  # Switch to latest linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable AMD video driver + Intel video driver via early KMS
  boot.initrd.kernelModules = [
    "amdgpu"
    "i915"
  ];
}
