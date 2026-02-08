_:

{
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Shanzem";
    userEmail = "owar125@gmail.com";
    extraConfig = {
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };
}
