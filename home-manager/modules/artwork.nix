{ config, lib, pkgs, inputs, ... }:

let
  artworkPath = "${inputs.artwork}/logos";
in
{
  home.file.".red-flake/artwork/logos/" = {
    source = artworkPath;
    recursive = true;
    force = true;
  };
}
