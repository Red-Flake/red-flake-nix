# Centralized cache configuration - Single Source of Truth
# This file is the authoritative list of binary caches for NixOS modules.
#
# NOTE: flake.nix nixConfig cannot import files (requires static values).
# When updating caches here, also update flake.nix nixConfig to match.
_:
{
  substituters = [
    "https://cache.nixos.org/"
    "https://nix-community.cachix.org/"
    "https://nyx.chaotic.cx"
    "https://claude-code.cachix.org"
    "https://mrn157.cachix.org/"
    "https://cache.garnix.io"
    "https://attic.xuyh0120.win/lantian"
  ];

  trustedPublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    # Both chaotic-nyx keys (same hash, different names due to upstream rename)
    "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
    "nyx.chaotic.cx-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
    "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
    "mrn157.cachix.org-1:A3KuzqTH/AeTFpDsu7Fql7KpZBJvFCkfNqxkL2+DZlc="
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
  ];
}
