# Example: VPS located in US with US locale
{ config, lib, pkgs, chaoticPkgs, inputs, isKVM, ... }:
let
  mkHost = (import ../../shared/mkHost.nix {
    inherit config lib pkgs chaoticPkgs inputs isKVM;
  }).mkHost;
in
mkHost "server" {
  hardwareConfig = ../vps/hardware.nix;
  hostname = "redflake-vps-us";
  hostId = "c0e3611d";

  # US server with US locale and timezone
  localeProfile = "us";

  extraModules = [
    ../vps/networking.nix
    ../vps/packages.nix
    ../vps/services.nix
  ];
}
