{ config
, lib
, pkgs
, modulesPath
, ...
}:

{
  # symlinks for metasploit-framework
  systemd.tmpfiles.rules =
    let
      createLink = src: dest: "L+ ${dest} - - - - ${src}";
    in
    [ (createLink "${pkgs.metasploit}/share/msf" "/usr/share/metasploit-framework") ];
}
