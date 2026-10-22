{ pkgs
, ...
}:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nmap
    nmapAutomator
    wafw00f
    nikto
    davtest
    cadaver
    whatweb
    onesixtyone
    whois
    eyewitness
    aquatone
    rpcbind
  ];
}
