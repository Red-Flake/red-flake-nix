{
  config,
  lib,
  pkgs,
  ...
}:
let
  optimusWidget = pkgs.fetchFromGitHub {
    owner = "enielrodriguez";
    repo = "optimus-gpu-switcher";
    rev = "b568fa349bf015fc71cb087a91800c81ae8afc9f";
    sha256 = "sha256-4/k6IhMuXpuBt8H8EgY6o00WE1V0JKliMycPpY6L5wM=";
  };
in
{
  home.activation.plasmaWidgets = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.kdePackages.kpackage}/bin/kpackagetool6 -t Plasma/Applet -i ${optimusWidget}
  '';
}
