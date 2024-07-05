{ config, lib, pkgsx86_64_v3, modulesPath, ... }:

{
  # Enable Wireshark
  programs.wireshark.enable = true;

  # Use Wireshark-QT
  programs.wireshark.package = pkgsx86_64_v3.wireshark;    
}
