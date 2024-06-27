{ config, lib, pkgs, ... }:

{
  home.activation.postActivate = ''
    # add flathub repo
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  '';
}
