{
  inputs,
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

let
  pwndbg = inputs.pwndbg.packages.${pkgs.system}.default;
in
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # edb   # disabled for now due to https://github.com/NixOS/nixpkgs/issues/449493
    pwndbg
    # gef   # disabled for now due to https://github.com/NixOS/nixpkgs/issues/449493
    gdb
  ];
}
