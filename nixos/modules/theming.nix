{ inputs
, pkgs
, ...
}:

let
  logoPath = "${inputs.artwork}/logos";
in
{
  # Fonts configuration for a smoother desktop experience
  fonts = {
    fontDir.enable = true;

    packages = with pkgs; [
      # Nerd Fonts
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.hack
      nerd-fonts.symbols-only

      # Standard Fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      dejavu_fonts

      # Microsoft replacement fonts
      corefonts
      vistafonts
    ];

    # Font rendering configuration
    fontconfig = {
      enable = true;
      antialias = true;
      hinting = {
        enable = true;
        style = "slight"; # "slight" is usually best for modern high-DPI screens
        autohint = true;
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };

      # Default font sets
      defaultFonts = {
        serif = [ "Noto Serif" "Liberation Serif" ];
        sansSerif = [ "Noto Sans" "Liberation Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" "FiraCode Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

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
