{ config, lib, pkgs, inputs, ... }:

{
  # Import other NixOS modules here
  imports = [
    # Installer-generated hardware configuration
    ./hardware-configuration.nix

    # Additional hardware configuration
    ./modules/hardware.nix

    # Bootloader configuration
    ./modules/bootloader.nix

    # GPU configuration
    ./modules/gpu.nix

    # Networking configuration
    ./modules/networking.nix

    # System packages
    ./modules/packages.nix

    # Sysctl settings
    ./modules/sysctl.nix

    # User settings
    ./modules/users.nix

    # Shell settings
    ./modules/setup-shell.nix

    # Services settings
    ./modules/services.nix

    # Desktop settings
    ./modules/desktop.nix

    # Virtualization settings
    ./modules/virtualisation.nix

    # Firefox settings
    ./modules/firefox-policies.nix

    # Setup Burp Suite
    ./modules/setup-burp.nix

    # Setup Neo4j
    ./modules/setup-neo4j.nix

    # performance optimizations
    ./modules/performance.nix

    # theming
    ./modules/theming.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
      # Enable deduplication
      auto-optimise-store = true;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  system.stateVersion = "23.05";

}
