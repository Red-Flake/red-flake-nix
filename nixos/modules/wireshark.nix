{ pkgs
, ...
}:

{
  # Enable Wireshark
  programs.wireshark.enable = true;

  # Use Wireshark-QT
  programs.wireshark.package = pkgs.wireshark;
}
