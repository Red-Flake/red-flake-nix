{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Letgamer";
    userEmail = "alexstephan005@gmail.com";
    extraConfig = {
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };
}
