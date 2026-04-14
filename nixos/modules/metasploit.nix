{ pkgsUnstable
, ...
}:

{
  # symlinks for metasploit-framework
  systemd.tmpfiles.rules =
    let
      createLink = src: dest: "L+ ${dest} - - - - ${src}";
    in
    [ (createLink "${pkgsUnstable.metasploit}/share/msf" "/usr/share/metasploit-framework") ];
}
