{ config, lib, pkgs, modulesPath, ... }:

{
  # symlinks for payloads
  systemd.tmpfiles.rules =
    let
      createLink = src: dest: "L+ ${dest} - - - - ${src}";
    in
    # symlink for payloadsallthethings
    [(createLink "${pkgs.payloadsallthethings}/share/payloadsallthethings" "/usr/share/payloads/payloadsallthethings")];
}
