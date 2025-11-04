{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  # set zsh as default shell:
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];
  environment.pathsToLink = [ "/share/zsh" ];
  programs.zsh.enable = true;
}
