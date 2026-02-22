{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    obsidian
    (hashcat.override { rocmSupport = true; })
  ];
}
