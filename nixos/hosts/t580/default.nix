# NixOS hosts config for my Thinkpad T580
{ config, lib, pkgs, inputs, ... }:

{
  # Import other NixOS modules here
  imports = [
    # Nix configuration
    ../../modules/nix.nix

    # Nixpkgs configuration
    ../../modules/nixpkgs.nix

    # Additional hardware configuration
    ../../modules/hardware.nix

    # Filesystems configuration
    ../../modules/filesystems.nix

    # Bootloader configuration
    ../../modules/bootloader.nix

    # Timezone configuration
    ../../modules/timezone.nix

    # GPU configuration
    ../../modules/gpu.nix

    # Networking configuration
    ../../modules/networking.nix

    # System packages
    ../../modules/packages

    # Sysctl settings
    ../../modules/sysctl.nix

    # User settings
    ./users.nix

    # Shell settings
    ../../modules/setup-shell.nix

    # Services settings
    ../../modules/services.nix

    # Desktop settings
    ../../modules/desktop.nix

    # Security settings
    ../../modules/security.nix

    # Virtualization settings
    ../../modules/virtualisation.nix

    # Setup Burp Suite
    ../../modules/setup-burp.nix

    # Setup Neo4j
    ../../modules/setup-neo4j.nix

    # Setup Wireshark
    ../../modules/wireshark.nix

    # performance optimizations
    ../../modules/performance.nix

    # theming
    ../../modules/theming.nix

    # symlinks for wordlists
    ../../modules/wordlists.nix

    # symlinks for webshells
    ../../modules/webshells.nix

    # symlinks for tools
    ../../modules/tools.nix

    # apply various system tweaks which are required for red-flake to work
    ../../modules/tweaks.nix

    # host specific configuration
    ../../../home-manager/pascal.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  # Set hostname
  networking.hostName = "redflake-t580";

  # Set fixed hostId (needed for ZFS)
  networking.hostId = "af84f01e";

  # Do not modify this value
  system.stateVersion = "23.05";

}