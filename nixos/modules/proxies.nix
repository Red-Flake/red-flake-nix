{ config
, lib
, pkgs
, modulesPath
, ...
}:

{
  # Enable Proxychains configuration
  programs.proxychains = {
    enable = true;
    package = pkgs.proxychains-ng;
    quietMode = true;
    proxies = { };
  };

  environment.etc."proxychains.conf".mode = "0644";
}
