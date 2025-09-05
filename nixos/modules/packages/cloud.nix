{ inputs, config, lib, pkgs, modulesPath, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #azure-cli   # build failed
    google-cloud-sdk
    awscli2
    cloudlist
    gcp-scanner
  ];
}
