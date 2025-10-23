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
    signing = {
      key = "${config.home.homeDirectory}/.ssh/id_redline-ssh.pub";
      signByDefault = true;
      format = "ssh";
    };
    extraConfig = {
      pull.rebase = true;
      push.autoSetupRemote = true;
      gpg.format = "ssh";
      #push.gpgSign = true;
    };
  };
}
