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

    # Security settings
    ./modules/security.nix

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

    # symlinks for wordlists
    ./modules/wordlists.nix

    # symlinks for webshells
    ./modules/webshells.nix

    # symlinks for tools
    ./modules/tools.nix

    # apply various system tweaks which are required for red-flake to work
    ./modules/tweaks.nix

  ];

  nixpkgs = {
    # You can add overlays here
    overlays = with inputs; [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
      chaotic.overlays.default
      nur.overlay

      # impacket overlay
      (import ./overlays/impacket-overlay)

      # responder overlay
      (import ./overlays/responder-overlay)

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })

      # temporary FIX for https://github.com/NixOS/nixpkgs/issues/325657  /  https://github.com/NixOS/nixpkgs/pull/325676
      (_: prev: {
        #python312 = prev.python312.override { packageOverrides = _: pysuper: { nose = pysuper.pynose; }; };
        pwndbg = prev.python311Packages.pwndbg;
        pwntools = prev.python311Packages.pwntools;
        ropper = prev.python311Packages.ropper;
        gef = prev.gef.override { python3 = prev.python311; };
        compiler-rt = prev.compiler-rt.override { python3 = prev.python311; };
        wordlists = prev.wordlists.override { wfuzz = prev.python311Packages.wfuzz; };
        thefuck = prev.thefuck.overridePythonAttrs { doCheck = false; };
        #xsser = prev.xsser.override { python3 = prev.python311; };
        ananicy-cpp = prev.ananicy-cpp.overrideAttrs { hardeningDisable = [ "zerocallusedregs" ]; };
      })

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
    optimise.automatic = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

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

      # Substituters
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];

      # Trusted public keys
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

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

  # Do not modify this value
  system.stateVersion = "23.05";

}
