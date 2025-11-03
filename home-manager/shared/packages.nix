# Shared package sets for home-manager configurations
{ pkgs, ... }:
{
  # Base packages that all users need
  base = with pkgs; [
    oh-my-zsh
    zsh-autosuggestions
    zsh-completions
    nix-zsh-completions
    zsh-syntax-highlighting
    zsh-powerlevel10k
    meslo-lgs-nf
    flatpak
  ];

  # Desktop/GUI packages for workstation users
  desktop = with pkgs; [
    papirus-icon-theme
    bibata-cursors
    sweet-nova
    kdePackages.kpackage
  ];

  # Gaming-related packages
  gaming = with pkgs; [
    mangohud
    steam-run
    steamtinkerlaunch
    steam-rom-manager
    umu-launcher
    protonup-qt
    protonup-ng
    heroic
    itch
    ludusavi
    # Wine
    winetricks
    wineWow64Packages.waylandFull
    bottles
  ];

  # AI/Development tools
  development = with pkgs; [
    claude-code
  ];

  # VPN and networking tools  
  networking = with pkgs; [
    eduvpn-client
  ];
}