{ config, lib, pkgs, inputs, ... }:
{
  # Import other NixOS modules here
  imports = [
    # Hardware configuration
    ./hardware-configuration.nix

    # System packages
    ./packages.nix

    # User settings
    ./users.nix

    # Firefox settings
    ./modules/firefox-policies.nix

    # Setup Burp Suite
    ./modules/setup-burp.nix
  ];

  nixpkgs = {
    overlays = [];
    config.allowUnfree = true;
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      flake-registry = "";
      auto-optimise-store = true;
    };
    channel.enable = false;
    registry = lib.mapAttrs (_: flake: { inherit flake; }) inputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") inputs;
  };

  networking.hostName = "nixos";

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "plasma";
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.lxd.enable = true;
  virtualisation.lxc.lxcfs.enable = true;

  system.stateVersion = "23.05";
}
