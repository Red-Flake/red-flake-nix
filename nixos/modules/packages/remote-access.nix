{ inputs, config, lib, pkgs, modulesPath, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    evil-winrm-patched
    openssh
    freerdp3
    rdesktop
    remmina
  ];
}
