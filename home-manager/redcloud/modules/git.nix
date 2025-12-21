{ config
, lib
, pkgs
, ...
}:

{
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Mag1cByt3s";
    userEmail = "ppeinecke@protonmail.com";
    extraConfig = {
      push = {
        autoSetupRemote = true;
      };
    };
  };
}
