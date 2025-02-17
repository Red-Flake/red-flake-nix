{ inputs, config, lib, pkgs, modulesPath, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #proxychains-ng
    ngrok
    sshuttle
    spose
    dnscat2
  ];

  # enable proxychains
  # TODO: @Shanzem fix: issue with rebuilding and re-creating config; similar to setup-hosts.nix;
  #programs.proxychains.enable = true;
}
