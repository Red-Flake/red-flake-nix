{
  inputs,
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # ettercap  # disabled for now due to https://github.com/NixOS/nixpkgs/issues/449493
    bettercap
    tcpdump
  ];
}
