{ inputs, config, lib, pkgs, modulesPath, ... }:

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
    # ncrack  # disable ncrack for now due to build errors
    # python313Packages.patator  # disable patator for now due to build errors
    fcrackzip
    medusa
  ];
}
