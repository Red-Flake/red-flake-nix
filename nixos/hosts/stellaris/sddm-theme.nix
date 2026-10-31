# Red Flake Noir login screen (SDDM) for this host only.
# Uses the same palette and wallpaper as pascal's desktop rice
# (home-manager/pascal/modules/rice). Other hosts keep the Breeze login.
{ lib
, pkgs
, ...
}:
let
  p = import ../../../home-manager/pascal/modules/rice/palette.nix { inherit lib; };
  wallpaper = ../../../assets/wallpapers/red-flake-noir-echo-2560x1600.png;

  theme = pkgs.sddm-astronaut.override {
    # Written to Themes/astronaut.conf.user, which overrides astronaut.conf.
    # Values are quoted like upstream's conf: unquoted, Qt's INI parser
    # would split values with commas (DateFormat) into lists.
    themeConfig = lib.mapAttrs (_: v: ''"${v}"'') {
      Background = "${wallpaper}";
      CropBackground = "true";
      DimBackground = "0.15";
      DimBackgroundColor = p.crust;
      ScreenWidth = "2560";
      ScreenHeight = "1600";

      Font = "Inter";
      FontSize = "13";
      RoundCorners = "14";
      HourFormat = "h:mm AP";
      DateFormat = "dddd, d MMMM";
      HeaderText = "";

      FormPosition = "left";
      HaveFormBackground = "false";
      PartialBlur = "true";
      FullBlur = "false";
      BlurMax = "48";
      Blur = "1.6";

      HeaderTextColor = p.text;
      DateTextColor = p.subtext;
      TimeTextColor = p.text;
      FormBackgroundColor = p.crust;
      BackgroundColor = p.crust;

      LoginFieldBackgroundColor = p.surface;
      PasswordFieldBackgroundColor = p.surface;
      LoginFieldTextColor = p.text;
      PasswordFieldTextColor = p.text;
      UserIconColor = p.crimson;
      PasswordIconColor = p.crimson;
      PlaceholderTextColor = p.muted;
      WarningColor = p.crimsonBright;

      LoginButtonTextColor = "#ffffff";
      LoginButtonBackgroundColor = p.crimson;
      SystemButtonsIconsColor = p.subtext;
      SessionButtonTextColor = p.subtext;
      VirtualKeyboardButtonTextColor = p.subtext;

      DropdownTextColor = p.text;
      DropdownSelectedBackgroundColor = p.crimson;
      DropdownBackgroundColor = p.surface;

      HighlightTextColor = "#ffffff";
      HighlightBackgroundColor = p.crimson;
      HighlightBorderColor = p.crimson;

      HoverUserIconColor = p.crimsonBright;
      HoverPasswordIconColor = p.crimsonBright;
      HoverSystemButtonsIconsColor = p.crimsonBright;
      HoverSessionButtonTextColor = p.crimsonBright;
      HoverVirtualKeyboardButtonTextColor = p.crimsonBright;

      HideVirtualKeyboard = "true";
      HideSystemButtons = "false";
      HideLoginButton = "false";
      ForceLastUser = "true";
      PasswordFocus = "true";
      HideCompletePassword = "true";
    };
  };
in
{
  services.displayManager.sddm = {
    theme = lib.mkForce "sddm-astronaut-theme";
    extraPackages = [ theme ];
  };

  environment.systemPackages = [ theme ];
  fonts.packages = [ pkgs.inter ];
}
