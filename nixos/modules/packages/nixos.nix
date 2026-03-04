{ inputs, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nix-index
    home-manager
    inputs.nix-alien.packages.${pkgs.stdenv.hostPlatform.system}.nix-alien
    treefmt
    nixpkgs-fmt
    deadnix
    statix
    nixfmt
    nix-prefetch-github
    nix-prefetch-git
    nix-prefetch-docker
    nix-prefetch-cvs
    nix-prefetch-svn
    nix-prefetch-hg
  ];
}
