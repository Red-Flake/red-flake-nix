{ config, lib, pkgsx86_64_v3, modulesPath, ... }:

{  
    # set zsh as default shell:
    users.defaultUserShell = pkgsx86_64_v3.zsh;
    environment.shells = with pkgsx86_64_v3; [ zsh ];
    environment.pathsToLink = [ "/share/zsh" ];
    programs.zsh.enable = true;
}