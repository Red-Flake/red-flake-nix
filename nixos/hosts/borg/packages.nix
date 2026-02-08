{ inputs, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    obsidian
  ];
}
