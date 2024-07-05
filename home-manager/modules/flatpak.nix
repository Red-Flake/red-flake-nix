{ config, lib, pkgs, ... }:

{
  home.activation.flatpak = ''
    # add flathub repo
    ${lib.getExe' pkgs.flatpak "flatpak"} remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  '';
}
