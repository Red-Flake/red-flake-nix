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
    "https://cache.garnix.io"
    "https://attic.xuyh0120.win/lantian"
    "https://nyx-cache.chaotic.cx/"
  ];

  trustedPublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    "nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk="
  ];
}
