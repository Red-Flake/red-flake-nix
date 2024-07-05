{ config, lib, pkgsx86_64_v3, inputs, ... }:

{
  # Import other NixOS modules here
  imports = [
    # Installer-generated hardware configuration
    ./hardware-configuration.nix

    # Additional hardware configuration
    ./modules/hardware.nix

    # Bootloader configuration
    ./modules/bootloader.nix

    # Timezone configuration
    ./modules/timezone.nix

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

    # Setup Burp Suite
    ./modules/setup-burp.nix

    # Setup Neo4j
    ./modules/setup-neo4j.nix

    # Setup Wireshark
    ./modules/wireshark.nix

    # performance optimizations
    ./modules/performance.nix

    # theming
    ./modules/theming.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = with inputs; [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
      chaotic-nyx.overlays.default
      nur.overlay

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

      # Allow legacy packages
      permittedInsecurePackages = [
        "openssl-1.1.1w"
      ];
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    # Don't warn about dirty flakes and accept flake configs by default
    extraOptions = ''
      accept-flake-config = true
      warn-dirty = false
    '';
    settings = {
      # Use available binary caches, this is not Gentoo
      # this also allows us to use remote builders to reduce build times and batter usage
      builders-use-substitutes = true;

      # Enable flakes and new 'nix' command
      experimental-features = [ "nix-command" "flakes" ];

      # Opinionated: disable global registry
      flake-registry = "";

      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;

      # Enable deduplication
      auto-optimise-store = true;

      # A few extra binary caches and their public keys
      # Enable Cachix Binary Cache for Chaotic-Nyx
      extra-substituters = [ "https://chaotic-nyx.cachix.org" ];
      extra-trusted-public-keys = [ "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8=" ];

      # Show more log lines for failed builds
      log-lines = 20;

      # Max number of parallel jobs
      max-jobs = "auto";
    };

    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  system.stateVersion = "23.05";

}
