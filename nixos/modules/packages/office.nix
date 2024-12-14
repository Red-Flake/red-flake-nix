{ inputs, config, lib, pkgs, modulesPath, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #libreoffice-qt6-fresh   # compiles from source and takes ages to compile
    freeoffice
    onlyoffice-desktopeditors
  ];
}
