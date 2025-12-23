# Optimized VPS configuration using shared profiles
{ config
, lib
, pkgs
, chaoticPkgs
, inputs
, isKVM
, ...
}:
let
  inherit ((import ../../shared/mkHost.nix {
    inherit
      config
      lib
      pkgs
      chaoticPkgs
      inputs
      isKVM
      ;
  })) mkHost;
in
mkHost "server" {
  hardwareConfig = ./hardware.nix;
  hostname = "redflake-vps";
  hostId = "c0e3611d"; # Fixed hostId for VPS

  extraModules = [
    ./networking.nix # VPS-specific networking
    ./packages.nix # VPS-specific packages
    ./services.nix # VPS-specific services
  ];
}
