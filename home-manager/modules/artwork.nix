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

  home.file.".local/share/icons/red-flake/" = {
    source = artworkPath;
    recursive = true;
    force = true;
  };
}
