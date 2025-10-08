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
    #azure-cli   # build failed
    google-cloud-sdk
    # awscli2   # disabled for now due to build failure; see: https://github.com/NixOS/nixpkgs/issues/449755
    cloudlist
    gcp-scanner
  ];
}
