{ inputs, config, lib, pkgs, modulesPath, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #cutter
    #cutterPlugins.jsdec
    #cutterPlugins.rz-ghidra
    ghidra-bin
    jadx
    radare2
    avalonia-ilspy
    inputs.nix-binary-ninja.packages.${system}.binary-ninja-free-wayland
  ];
}
