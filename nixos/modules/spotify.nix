{ config
, pkgs
, lib
, inputs
, ...
}:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
  # Enables the use of the GPU for scrolling
  scroll = pkgs.fetchFromGitHub {
    owner = "iHelops";
    repo = "smooth-scrolling";
    rev = "10b1aebdbfbb9c7cc04c8b33e074f653437a0dd0";
    sha256 = "sha256-KlEmL6pESgODTqkT0a4Zbj2Qga6t8fQOsyBsGvY+504=";
  };
in
{
  programs.spicetify = {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      hidePodcasts
      shuffle # shuffle+ (special characters are sanitized out of extension names)
      fullScreen
      volumePercentage
      {
        src = "${scroll}/dist";
        name = "smooth-scrolling.js";
      }
    ];
    enabledCustomApps = with spicePkgs.apps; [
      lyricsPlus # needed for lyrics on the fullscreen extension
    ];
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "mocha";
    wayland = true;
  };
}
