{
  inputs,
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    cutter
    cutterPlugins.jsdec
    cutterPlugins.rz-ghidra
    ghidra-bin
    # jadx # disable jadx for now due to issues with arrow / flight
    radare2
    avalonia-ilspy
  ];

  programs.binary-ninja = {
    enable = true;
    package = pkgs.binary-ninja-free-wayland;
  };
}
