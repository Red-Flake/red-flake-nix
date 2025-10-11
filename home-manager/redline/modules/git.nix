{ config, lib, pkgs, ... }:

{
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName  = "Letgamer";
    userEmail = "alexstephan005@gmail.com";
    extraConfig = {
      push = { autoSetupRemote = true; };
    };
  };
}
