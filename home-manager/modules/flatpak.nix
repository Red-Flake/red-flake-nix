{ config, lib, pkgsx86_64_v3, ... }:

{
  home.activation.flatpak = ''
    # add flathub repo
    ${lib.getExe' pkgsx86_64_v3.flatpak "flatpak"} remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  '';
}
