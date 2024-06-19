{ config, lib, pkgs, modulesPath, ... }:

{
    # set /etc/issue
    environment.etc = {
        issue.text = ''
        Welcome to

        ██████  ███████ ██████      ███████ ██       █████  ██   ██ ███████ 
        ██   ██ ██      ██   ██     ██      ██      ██   ██ ██  ██  ██      
        ██████  █████   ██   ██     █████   ██      ███████ █████   █████   
        ██   ██ ██      ██   ██     ██      ██      ██   ██ ██  ██  ██      
        ██   ██ ███████ ██████      ██      ███████ ██   ██ ██   ██ ███████ 
                                                                    
        '';
    };

    # catppuccin
    catppuccin.enable = true;
    catppuccin.flavor = "mocha";
    catppuccin.accent = "pink";

}
