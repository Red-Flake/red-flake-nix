{ inputs, config, lib, pkgs, modulesPath, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    binwalk
    foremost
    scalpel
    pdf-parser
    pdfid
    exiftool
    # zeek    # disable zeek for now due to build errors
    oletools
  ];
}
