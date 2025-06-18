{ inputs, config, lib, pkgs, modulesPath, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nix-index
    home-manager
    inputs.nix-alien.packages.${system}.nix-alien
  ];
}
