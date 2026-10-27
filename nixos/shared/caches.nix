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
    # nix-cachyos-kernel: new URL + key after the 2026-10 compromise
    # (xddxdd/nix-cachyos-kernel#110). Never re-add the old
    # attic.xuyh0120.win URL or the lantian:EeAU... key.
    "https://cache.lantian.pub/lantian"
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
    "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="
    "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
  ];
}
