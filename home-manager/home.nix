# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs, lib, config, pkgs, ... }:
{
  # import other home-manager
  imports = [
    ./modules/zsh.nix
    ./modules/msf.nix
    ./modules/thefuck.nix
  ];

  # disable warning about mismatched version between Home Manager and Nixpkgs
  home.enableNixpkgsReleaseCheck = false;

  nixpkgs = {
    overlays = [];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  home.packages = with pkgs; [
    oh-my-zsh
    zsh-autosuggestions
    zsh-completions
    nix-zsh-completions
    zsh-syntax-highlighting
    zsh-powerlevel10k
    meslo-lgs-nf
    thefuck
  ];

  xsession.enable = true;

  programs.home-manager.enable = false;
  programs.git.enable = true;
}
