# NixOS hosts config for TUXEDO Stellaris 16 Gen7
{
  config,
  lib,
  pkgs,
  chaoticPkgs,
  inputs,
  poetry2nix,
  isKVM,
  tuxedo-nixos,
  ...
}:
{
  # Import other NixOS modules here
  imports = [
    # Nix configuration
    ../../modules/nix.nix

    # Nixpkgs configuration
    ../../modules/nixpkgs.nix

    # Additional hardware configuration for TUXEDO Stellaris 16 Gen7
    ./hardware.nix

    # Nvidia hardware configuration for TUXEDO Stellaris 16 Gen7
    ./nvidia.nix

    # Additional general hardware configuration
    ../../modules/hardware.nix

    # Filesystems configuration
    ../../modules/filesystems.nix

    # Impermanence configuration
    ../../modules/impermanence.nix

    # Bootloader configuration
    ../../modules/bootloader.nix

    # Networking configuration
    ../../modules/networking.nix

    # Hosts configuration
    ../../modules/setup-hosts.nix

    # System packages
    ../../modules/packages

    # Additional packages for TUXEDO Stellaris 16 Gen7
    ./packages.nix

    # FHS tweaks
    ../../modules/fhs.nix

    # Sysctl settings
    ../../modules/sysctl.nix

    # User settings
    ../../modules/users.nix

    # Shell settings
    ../../modules/setup-shell.nix

    # Services settings
    ../../modules/services.nix

    # KDE settings
    ../../modules/kde.nix

    # Avatar settings
    ./avatar.nix

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

    # XDG settings
    ../../modules/xdg.nix

    # theming
    ../../modules/theming.nix

    # symlinks for wordlists
    ../../modules/wordlists.nix

    # symlinks for webshells
    ../../modules/webshells.nix

    # symlinks for payloads
    ../../modules/payloads.nix

    # symlinks for exploits
    ../../modules/exploits.nix

    # symlinks for tools
    ../../modules/tools.nix

    # symlinks for metasploit-framework
    ../../modules/metasploit.nix

    # apply various system tweaks which are required for red-flake to work
    ../../modules/tweaks.nix

    # SSH settings
    ../../modules/ssh.nix

    # Proxy settings
    ../../modules/proxies.nix

    # AppImage settings
    ../../modules/appimage.nix

    # BloodHound CE
    #../../modules/bloodhound.nix

    # Gaming
    ./gaming.nix

    # Ollama
    ./ollama.nix
  ];

  # Set hostname
  networking.hostName = "redflake-stellaris16";

  # Set fixed hostId (needed for ZFS)
  networking.hostId = "aff4a050";

  # Set timezone
  time.timeZone = "Europe/Berlin";

  # Set locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Set extra locale settings
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    # week starts on a Monday
    LC_TIME = "en_GB.UTF-8";
  };

  # Do not modify this value
  system.stateVersion = "23.05";

}
