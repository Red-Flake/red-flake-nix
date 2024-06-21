# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs, lib, config, pkgs, ... }:
{
  # import other home-manager
  imports = [
    inputs.nur.hmModules.nur
    ./modules/zsh.nix
    ./modules/msf.nix
    ./modules/thefuck.nix
    ./modules/fastfetch.nix
    ./modules/bloodhound.nix
    ./modules/plasma-manager.nix
    ./modules/konsole.nix
    ./modules/dolphin.nix
    ./modules/artwork.nix
    ./modules/firefox.nix
  ];

  # disable warning about mismatched version between Home Manager and Nixpkgs
  home.enableNixpkgsReleaseCheck = false;

  home.packages = with pkgs; [
    oh-my-zsh
    zsh-autosuggestions
    zsh-completions
    nix-zsh-completions
    zsh-syntax-highlighting
    zsh-powerlevel10k
    meslo-lgs-nf
    thefuck
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    kdePackages.qt6ct
  ];

  home.sessionVariables = {
    # This should be default soon
    MOZ_ENABLE_WAYLAND = 1;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Breeze-Dark";
      package = pkgs.libsForQt5.breeze-gtk;
    };
    gtk3 = {
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "breeze";
  };

  xsession.enable = true;

  programs.home-manager.enable = false;
  programs.git.enable = true;
}
