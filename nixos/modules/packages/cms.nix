{ inputs, config, lib, pkgs, modulesPath, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wpscan
    joomscan
    droopescan
    JoomlaScan
    joomla-brute
  ];
}
