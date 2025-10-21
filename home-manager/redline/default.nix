# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  user,
  ...
}:
let
  # Clean pkgs for home-manager
  homePkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true; # Optional
  };
in
{
  # import other home-manager modules
  imports = [
    inputs.nur.modules.homeManager.default
    inputs.plasma-manager.homeModules.plasma-manager
    inputs.nixcord.homeModules.nixcord
    ../redflake/modules/dconf.nix
    ../redflake/modules/artwork.nix
    ../redflake/modules/theme.nix
    ../redflake/modules/zsh.nix
    ../redflake/modules/msf.nix
    ../redflake/modules/fastfetch.nix
    ../redflake/modules/bloodhound.nix
    ../redflake/modules/kwallet.nix
    ../redflake/modules/konsole.nix
    ../redflake/modules/burpsuite.nix
    ../redflake/modules/psd.nix
    ../redflake/modules/flatpak.nix
    ../redflake/modules/virtualisation.nix
    ../redflake/modules/desktop-files.nix
    ../redflake/modules/xdg.nix
    ../redflake/modules/ssh-agent.nix
    ../redflake/modules/jadx.nix
    ../redflake/modules/bat.nix
    ../redflake/modules/services.nix
    ../redflake/modules/direnv.nix
    ./modules/ssh-config.nix
    ./modules/vscode.nix
    ./modules/git.nix
    ./modules/firefox.nix
    ./modules/monitors.nix
    ./modules/plasma-manager.nix
    ./modules/vesktop.nix
  ];

  home = {
    # set username
    username = "${user}";

    # set home directory
    homeDirectory = "/home/${user}";

    # do not change this value!
    stateVersion = "23.05";

    # disable warning about mismatched version between Home Manager and Nixpkgs
    enableNixpkgsReleaseCheck = false;

    # set user packages
    packages = with homePkgs; [
      papirus-icon-theme
      bibata-cursors
      sweet-nova
      oh-my-zsh
      zsh-autosuggestions
      zsh-completions
      nix-zsh-completions
      zsh-syntax-highlighting
      zsh-powerlevel10k
      meslo-lgs-nf
      flatpak
      eduvpn-client
    ];

    # set user session variables
    sessionVariables = {
      # This should be default soon
      MOZ_ENABLE_WAYLAND = 1;
    };
  };

  # enable xsession
  xsession.enable = true;

  # this is required for NixOS home-manager to work!
  # let NixOS manage home-manager
  programs.home-manager.enable = false;
}
