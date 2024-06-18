{ pkgs, ... }:

let
  inherit (inputs.home-manager) lib;
in
{
  imports = [
    "${inputs.plasma-manager}/modules"
  ];

  programs.plasma = {
    enable = true;
  };
}
