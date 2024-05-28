{ config, lib, pkgs, inputs, ... }:
{
  # Import other NixOS modules here
  imports = [
    # Hardware configuration
    ./hardware-configuration.nix

    # System packages
    ./packages.nix

    # User settings
    ./users.nix

    # Services settings
    ./modules/services.nix

    # Firefox settings
    ./modules/firefox-policies.nix

    # Setup Burp Suite
    ./modules/setup-burp.nix
  ];

  nixpkgs = {
    overlays = [];
    config.allowUnfree = true;
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      flake-registry = "";
      auto-optimise-store = true;
    };
    channel.enable = false;
    registry = lib.mapAttrs (_: flake: { inherit flake; }) inputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") inputs;
  };

  networking.hostName = "nixos";

  

  virtualisation.docker.enable = true;
  virtualisation.lxd.enable = true;
  virtualisation.lxc.lxcfs.enable = true;

  # set zsh as default shell:
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];
  environment.pathsToLink = [ "/share/zsh" ];
  programs.zsh.enable = true;

  system.stateVersion = "23.05";
}
