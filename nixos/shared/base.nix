# Base NixOS configuration shared across all hosts
{ config, lib, pkgs, chaoticPkgs, inputs, isKVM, hostType ? "security", ... }:
let
  overlayConfig = import ./overlays.nix { inherit inputs; };
in
{
  # Common imports for all hosts
  imports = [
    # Core system configuration with optimized cache
    ./cache.nix
    ../modules/nixpkgs.nix
    ../modules/hardware.nix
    ../modules/filesystems.nix
    ../modules/impermanence.nix
    ../modules/bootloader.nix
    
    # Network and connectivity
    ../modules/networking.nix
    ../modules/setup-hosts.nix
    ../modules/ssh.nix
    
    # Conditional packages based on host type
    (import ./conditional-packages.nix { inherit lib hostType; })
    
    # Core system environment
    ../modules/fhs.nix
    ../modules/sysctl.nix
    ../modules/users.nix
    ../modules/setup-shell.nix
    ../modules/services.nix
    
    # Desktop environment (conditional)
    ../modules/xdg.nix
    ../modules/theming.nix
    
    # System optimization and tools
    ../modules/performance.nix
    ../modules/appimage.nix
    ../modules/tweaks.nix
  ] 
  # Conditionally import desktop modules
  ++ lib.optionals (builtins.elem hostType ["security" "desktop"]) [
    ../modules/kde.nix
  ]
  # Conditionally import security modules  
  ++ lib.optionals (hostType == "security") [
    ../modules/security.nix
    ../modules/virtualisation.nix
  ];

  # Set overlays based on host type
  nixpkgs.overlays = overlayConfig.getOverlaysFor hostType;

  # Only truly universal settings here - locale/timezone are host-specific
  system.stateVersion = "23.05";
}