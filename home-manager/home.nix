# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs, lib, config, pkgs, ... }:
{
  # import other home-manager
  imports = [
    inputs.nur.hmModules.nur
    ./modules/artwork.nix
    ./modules/theme.nix
    ./modules/zsh.nix
    ./modules/msf.nix
    #./modules/thefuck.nix
    ./modules/fastfetch.nix
    ./modules/bloodhound.nix
    ./modules/plasma-manager.nix
    ./modules/konsole.nix
    ./modules/dolphin.nix
    ./modules/firefox.nix
    ./modules/burpsuite.nix
    ./modules/psd.nix
    ./modules/flatpak.nix
    ./modules/virtualisation.nix
    ./modules/desktop-files.nix
    ./modules/xdg.nix
  ];

  # disable warning about mismatched version between Home Manager and Nixpkgs
  home.enableNixpkgsReleaseCheck = false;

  home.packages = with pkgs; [
    papirus-icon-theme
    bibata-cursors
    oh-my-zsh
    zsh-autosuggestions
    zsh-completions
    nix-zsh-completions
    zsh-syntax-highlighting
    zsh-powerlevel10k
    meslo-lgs-nf
    thefuck
    flatpak
  ];

  home.sessionVariables = {
    # This should be default soon
    MOZ_ENABLE_WAYLAND = 1;
  };

  xsession.enable = true;

  programs.home-manager.enable = false;
  programs.git.enable = true;
}
