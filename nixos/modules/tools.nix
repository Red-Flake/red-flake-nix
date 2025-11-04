{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  toolsPath = "${inputs.tools}";
in
{
  # symlinks for tools
  systemd.tmpfiles.rules =
    let
      createLink = src: dest: "L+ ${dest} - - - - ${src}";
    in
    [ (createLink "${toolsPath}" "/usr/share/tools") ];
}
