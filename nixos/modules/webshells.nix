{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  webshellsPath = "${inputs.webshells}";
in
{
  # symlinks for webshells
  systemd.tmpfiles.rules =
    let
      createLink = src: dest: "L+ ${dest} - - - - ${src}";
    in
    [ (createLink "${webshellsPath}" "/usr/share/webshells") ];
}
