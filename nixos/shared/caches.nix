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
    # attic.xuyh0120.win/lantian (nix-cachyos-kernel) removed 2026-10-19: its
    # servers were compromised (xddxdd/nix-cachyos-kernel#110). Do not re-add the
    # old lantian: key; wait for a re-keyed cache.
    "https://nyx-cache.chaotic.cx/"
    "https://noctalia.cachix.org/"
    # NixOS CUDA team cache: pre-built cudaSupport packages (opencv, ollama, ...)
    "https://cache.nixos-cuda.org"
  ];

  trustedPublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk="
    "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
  ];
}
