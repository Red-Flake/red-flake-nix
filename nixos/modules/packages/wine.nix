{ pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wineWow64Packages.stable
    winetricks
    wineWow64Packages.waylandFull
    bottles
  ];
}
