{ inputs, config, lib, pkgs, modulesPath, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    python311Packages.binwalk-full
    foremost
    scalpel
    pdf-parser
    pdfid
    exiftool
    zeek
    oletools
  ];
}