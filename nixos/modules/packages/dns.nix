{ pkgs, pkgsUnstable, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    dig
    pkgsUnstable.dnsenum
    pkgsUnstable.dnsrecon
    fierce
    subfinder
  ];
}
