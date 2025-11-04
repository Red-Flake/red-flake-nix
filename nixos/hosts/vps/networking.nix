{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  networking.firewall.enable = false; # This one is necessary to expose ports to the netwok. Usefull for smbserver, responder, http.server, ...
  networking.nftables.enable = false; # This one is necessary to expose ports to the netwok. Usefull for smbserver, responder, http.server, ...
}
