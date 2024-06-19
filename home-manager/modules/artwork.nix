{ config, lib, pkgs, ... }:

let
  artworkPath = builtins.fetchGit {
    url = "https://github.com/Red-Flake/artwork.git";
    ref = "main";
  };
in
{
  home.file.".red-flake/artwork/logos/" = {
    source = "${artworkPath}/logos";
    recursive = true;
    force = true;
  };
}
