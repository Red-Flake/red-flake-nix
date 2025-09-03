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
    #cutter
    #cutterPlugins.jsdec
    #cutterPlugins.rz-ghidra
    ghidra-bin
    #jadx     disable jadx for now due to issues with arrow / flight
    radare2
    avalonia-ilspy
    # disable binary-ninja for now due to hash mismatch issues
    #inputs.nix-binary-ninja.packages.${system}.binary-ninja-free-wayland
  ];
}
