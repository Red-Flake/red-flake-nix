{ config, lib, pkgs, modulesPath, inputs, ... }:

{
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
       experimental-features = [ 
        "nix-command"
        "flakes"
       ];
  
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
       extra-substituters = [ 
        "https://chaotic-nyx.cachix.org" 
       ];
       extra-trusted-public-keys = [ 
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8=" 
       ];
  
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
}
