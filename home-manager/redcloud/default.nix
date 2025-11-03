# Optimized home-manager configuration using shared profiles
{ inputs, lib, config, pkgs, user, ... }:
let
  mkUser = (import ../shared/mkUser.nix { inherit inputs lib pkgs; }).mkUser;
in
mkUser "redcloud" {
  extraModules = [
    ./modules/xdg.nix  # User-specific XDG config
    ./modules/ssh-config.nix  # User-specific SSH config
  ];
}
