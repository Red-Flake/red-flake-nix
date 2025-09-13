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
    ./modules/git.nix
    ./modules/dconf.nix
    ./modules/artwork.nix
    ./modules/theme.nix
    ./modules/zsh.nix
    ./modules/msf.nix
    ./modules/fastfetch.nix
    ./modules/bloodhound.nix
    ./modules/plasma-manager.nix
    ./modules/optimus-gpu-switcher-widget.nix
    ./modules/kwallet.nix
    ./modules/konsole.nix
    ./modules/firefox.nix
    ./modules/burpsuite.nix
    ./modules/psd.nix
    ./modules/flatpak.nix
    ./modules/virtualisation.nix
    ./modules/desktop-files.nix
    ./modules/xdg.nix
    ./modules/ssh-agent.nix
    ./modules/ssh-config.nix
    ./modules/jadx.nix
    ./modules/bat.nix
    ./modules/services.nix
    ./modules/vscode.nix
    ./modules/direnv.nix
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
      kdePackages.kpackage

      # gaming related package
      mangohud
      steam-run
      steamtinkerlaunch
      steam-rom-manager
      umu-launcher
      protonup-qt
      protonup-ng
      lutris
      heroic
      itch
      ludusavi

      # wine
      winetricks
      wineWow64Packages.waylandFull
      bottles
    ];

    # set user session variables
    sessionVariables = {
      # This should be default soon
      MOZ_ENABLE_WAYLAND = 1;

      # Set steam proton path
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\\\${HOME}/.steam/root/compatibilitytools.d";

      # Set terminal to konsole
      TERMINAL = "konsole";

      # Set global xcursor size to 24; this matches the default cursor size in KDE Plasma of 24
      XCURSOR_SIZE = "24";
    };

  };

  # enable xsession
  xsession.enable = true;

  # this is required for NixOS home-manager to work!
  # let NixOS manage home-manager
  programs.home-manager.enable = false;

}
