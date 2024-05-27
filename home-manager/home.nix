# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs, lib, config, pkgs, ... }:
{
  # You can import other home-manager modules here
  imports = [
    ./modules/zsh.nix
  ];

  home.packages = with pkgs; [
    pkgs.oh-my-zsh
  ];

  xsession.enable = true;

  programs.home-manager.enable = false;
  programs.git.enable = true;
}
