# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs, lib, config, pkgs, ... }:
{
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    #
    
    # import firefox.nix
    #
    #./modules/firefox.nix

    # import zsh.nix
    ./modules/zsh.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # Set your username
  home = {
    username = "pascal";
    homeDirectory = "/home/pascal";
    stateVersion = "23.05"; # https://wiki.nixos.com/wiki/FAQ/When_do_I_update_stateVersion
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];
  home.packages = with pkgs; [
    pkgs.oh-my-zsh
  ];

  # Home Manager includes a number of services intended to run in a graphical session, for example xscreensaver and dunst. 
  # Unfortunately, such services will not be started automatically unless you let Home Manager start your X session.
  xsession.enable = true;
  # xsession.windowManager.command = "…";

  # Set programs.home-manager.enable to false so it can be managed by NixOS!
  programs.home-manager.enable = false;
  programs.git.enable = true;
  programs.zsh.enable = true;
  # programs.firefox.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
