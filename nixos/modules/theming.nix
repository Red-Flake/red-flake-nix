{ inputs
, config
, lib
, pkgs
, modulesPath
, ...
}:

let
  logoPath = "${inputs.artwork}/logos";
  iconPath = "${inputs.artwork}/icons";
  wallpaperPath = "${inputs.artwork}/wallpapers";
in
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
      LOGO="${logoPath}/RedFlake_Logo_128x128px.png"
      NAME="Red Flake"
      PRETTY_NAME="Red Flake"
      SUPPORT_URL="https://github.com/Red-Flake/"
      VERSION="rolling"
      VERSION_CODENAME=rolling
      VERSION_ID="rolling"
    '';
  };

}
