{
  inputs,
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nmap
    nmapAutomator
    # wafw00f     # diabled for now due to failing build; see: https://github.com/NixOS/nixpkgs/issues/449737
    nikto
    davtest
    joomscan
    whatweb
    onesixtyone
    whois
    eyewitness
    aquatone
    rpcbind
  ];
}
