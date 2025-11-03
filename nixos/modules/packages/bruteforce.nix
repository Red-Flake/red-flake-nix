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
    ffuf
    feroxbuster
    gobuster
    kerbrute
    hashcat
    john
    thc-hydra
    ncrack
    # python312Packages.patator   # is marked as broken
    fcrackzip
    medusa
  ];
}
