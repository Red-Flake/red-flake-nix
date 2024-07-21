{ config, lib, pkgs, modulesPath, ... }:

{
  # make /etc/hosts writable on demand
  environment.etc.hosts.mode = "0644";

  # enable nix-ld; needed for `nix-alien-ld`
  programs.nix-ld.enable = true;
}
