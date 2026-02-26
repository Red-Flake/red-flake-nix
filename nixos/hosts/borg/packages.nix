{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    obsidian
    google-chrome
  ];
}
