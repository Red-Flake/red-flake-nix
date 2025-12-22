{ lib
, pkgs
, inputs
, ...
}:

let
  nixCaches =
    let
      flakeConfig = inputs.self.nixConfig or { };
    in
    {
      substituters =
        lib.unique (
          [
            "https://cache.nixos.org/"
          ]
          ++ (flakeConfig."extra-substituters" or [ ])
        );
      trustedPublicKeys = lib.unique (flakeConfig."extra-trusted-public-keys" or [ ]);
    };
in
{
  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      # Switch to stable Lix package manager
      package = pkgs.lixPackageSets.stable.lix;

      gc = {
        # automatic = true; # Disabled due to conflict with nh
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

        # Trust wheel group users for using extra substituters
        trusted-users = [ "root" "@wheel" ];

        # Enable flakes and new 'nix' command
        experimental-features = [
          "nix-command"
          "flakes"
        ];

        # Opinionated: disable global registry
        flake-registry = "";

        # Enable deduplication
        auto-optimise-store = true;

        # Don't warn about dirty flakes
        accept-flake-config = true;
        warn-dirty = false;

        # Performance optimizations for faster rebuilds
        keep-outputs = true;
        keep-derivations = true;

        # Additional performance settings
        eval-cache = true;
        narinfo-cache-positive-ttl = 3600;
        narinfo-cache-negative-ttl = 60;
        fsync-metadata = false; # Faster on SSDs
        connect-timeout = 10; # Faster timeout handling
        max-substitution-jobs = 128; # Increased parallel downloads
        http-connections = 128; # Max http connections (default 25)
        keep-build-log = false; # Reduce storage overhead
        compress-build-log = true;
        cores = 0; # Use all available CPU cores
        max-jobs = "auto"; # Auto-detect based on CPU cores

        # Rebuild performance
        preallocate-contents = true;
        min-free = 1024 * 1024 * 1024; # 1GB free before pausing builds

        # Slightly higher logs for debugging without flooding
        log-lines = 50;

        # Store optimization settings
        fallback = true; # Fall back to building if substitution fails

        # Substituters
        inherit (nixCaches) substituters;

        # Trusted public keys
        trusted-public-keys = nixCaches.trustedPublicKeys;
      };

      # Opinionated: disable channels
      channel.enable = false;

      # Opinionated: make flake registry and nix path match flake inputs
      # Add each flake input as a registry and nix_path
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

  # Enable nh
  # https://github.com/nix-community/nh?tab=readme-ov-file#installation
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
  };
}
