{ config, lib, pkgs, inputs, ... }:

{
  # Import other NixOS modules here
  imports = [
    # Hardware configuration
    ./hardware-configuration.nix

    # System packages
    ./modules/packages.nix

    # User settings
    ./modules/users.nix

    # Shell settings
    ./modules/setup-shell.nix

    # Services settings
    ./modules/services.nix

    # Virtualization settings
    ./modules/virtualisation.nix

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

  networking.hostName = "redflake";

  system.stateVersion = "23.05";
}
