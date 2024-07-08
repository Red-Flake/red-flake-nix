{ config, lib, pkgs, modulesPath, ... }:

{
  # symlinks for wordlists
  systemd.tmpfiles.rules =
    let
      createLink = src: dest: "L+ ${dest} - - - - ${src}";
    in
    [(createLink "${pkgs.wordlists}/share/wordlists" "/usr/share/wordlists")];
}
