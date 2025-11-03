# Example: Optimized KVM configuration with configurable locale
{ config, lib, pkgs, chaoticPkgs, inputs, isKVM, ... }:
let
  mkHost = (import ../../shared/mkHost.nix {
    inherit config lib pkgs chaoticPkgs inputs isKVM;
  }).mkHost;
in
mkHost "security" {
  hardwareConfig = ../kvm/hardware.nix;
  hostname = "redflake-kvm";
  
  # Use German region with English interface (default for Red-Flake)
  localeProfile = "german-en";
  
  extraModules = [
    # KVM host might need these specific modules
  ];
  
  extraConfig = {
    # Any KVM-specific configuration
  };
}