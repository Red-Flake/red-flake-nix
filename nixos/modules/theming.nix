{ config, lib, pkgs, modulesPath, ... }:

{
    environment.etc = {

         # set /etc/issue
        issue.text = ''
            Welcome to

            ██████  ███████ ██████      ███████ ██       █████  ██   ██ ███████ 
            ██   ██ ██      ██   ██     ██      ██      ██   ██ ██  ██  ██      
            ██████  █████   ██   ██     █████   ██      ███████ █████   █████   
            ██   ██ ██      ██   ██     ██      ██      ██   ██ ██  ██  ██      
            ██   ██ ███████ ██████      ██      ███████ ██   ██ ██   ██ ███████ 

        '';

        # set /etc/os-release
        os-release.text = ''
            ANSI_COLOR="1;34"
            BUG_REPORT_URL="https://github.com/Red-Flake/red-flake-nix/issues"
            BUILD_ID="rolling"
            DOCUMENTATION_URL="https://github.com/Red-Flake/red-flake-nix/wiki"
            HOME_URL="https://github.com/Red-Flake/"
            ID=redflake
            IMAGE_ID="rolling"
            IMAGE_VERSION="rolling"
            LOGO="nix-snowflake"
            NAME="Red Flake"
            PRETTY_NAME="Red Flake"
            SUPPORT_URL="https://github.com/Red-Flake/"
            VERSION="rolling"
            VERSION_CODENAME=rolling
            VERSION_ID="rolling"
        '';
    };

    


}
