# Centralized cache configuration for optimal build performance
{ lib, ... }:
{
  # Optimized nix settings for faster builds
  nix = {
    settings = {
      # Enable flakes and new CLI
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      extra-deprecated-features = [
        "url-literals"
      ];

      # Build performance optimizations
      max-jobs = "auto";
      cores = 0; # Use all available cores

      # Cache and substituter settings
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org/"
        "https://nyx.chaotic.cx"
        "https://claude-code.cachix.org"
        #"https://cache.garnix.io"
        "https://attic.xuyh0120.win/lantian"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "nyx.chaotic.cx-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
        #"cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      ];

      # Performance tweaks
      builders-use-substituters = true;
      auto-optimise-store = true;

      # Build isolation and reproducibility
      sandbox = true;

      # Keep build dependencies for debugging
      keep-outputs = true;
      keep-derivations = true;

      # Garbage collection settings
      min-free = lib.mkDefault (1024 * 1024 * 1024); # 1GB
      max-free = lib.mkDefault (5 * 1024 * 1024 * 1024); # 5GB
    };

    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Automatic store optimization
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };
}
