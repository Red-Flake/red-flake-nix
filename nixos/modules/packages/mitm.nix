{ inputs, config, lib, pkgs, modulesPath, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    responder-patched
    #ssh-mitm     # disable for now due to failing build of python313Packages.paramiko
  ];
}
