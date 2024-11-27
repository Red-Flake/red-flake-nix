{ inputs, config, lib, pkgs, modulesPath, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    samba
    smbmap
    enum4linux-ng
    smbclient-ng
    SMB_Killer
  ];
}
