{ config, lib, pkgs, inputs, ... }:
{

  gtk = {
    enable = true;
    theme = {
      name = "Breeze-Dark";
      package = pkgs.kdePackages.breeze-gtk;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };
    gtk2 = {
      configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    };
    gtk3 = {
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
    gtk4 = {
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
  };

  # force creation of .gtkrc-2.0 otherwise home-manager will fail
  home.file.${config.gtk.gtk2.configLocation}.force = true;

  # Fix GTK themes not applied in Wayland
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        gtk-theme = lib.mkForce "Breeze-Dark";
        icon-theme = lib.mkForce "Papirus-Dark";
        color-scheme = lib.mkForce "prefer-dark";
        cursor-theme = lib.mkForce "Bibata-Modern-Classic";
        cursor-size = lib.mkForce 24;
      };
    };
  };

  # Set X11 cursor theme
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    size = 24;
  };

  # Color scheme Gradient Dark
  # https://store.kde.org/p/2078411
  # https://github.com/L4ki/Gradient-Plasma-Themes/tree/main/Gradient%20Color%20Schemes
  home.file.".local/share/color-schemes/GradientDarkColorScheme.colors".text = ''
    [ColorEffects:Disabled]
    Color=56,56,56
    ColorAmount=0
    ColorEffect=0
    ContrastAmount=0.65
    ContrastEffect=1
    IntensityAmount=0.1
    IntensityEffect=2

    [ColorEffects:Inactive]
    ChangeSelectionColor=true
    Color=112,111,110
    ColorAmount=0.025000000000000001
    ColorEffect=2
    ContrastAmount=0.10000000000000001
    ContrastEffect=2
    Enable=false
    IntensityAmount=0
    IntensityEffect=0

    [Colors:Button]
    BackgroundAlternate=28,32,47
    BackgroundNormal=31,36,52
    DecorationFocus=0,107,107
    DecorationHover=0,117,117
    ForegroundActive=78,81,172
    ForegroundInactive=139,145,157
    ForegroundLink=0,121,181
    ForegroundNegative=150,75,112
    ForegroundNeutral=0,121,181
    ForegroundNormal=195,199,209
    ForegroundPositive=0,170,127
    ForegroundVisited=170,85,255

    [Colors:Complementary]
    BackgroundAlternate=28,32,47
    BackgroundNormal=28,32,47
    DecorationFocus=0,107,107
    DecorationHover=0,117,117
    ForegroundLink=0,121,181
    ForegroundNegative=150,75,112
    ForegroundNeutral=0,121,181
    ForegroundPositive=0,170,127
    ForegroundVisited=170,85,255

    [Colors:Selection]
    BackgroundAlternate=29,153,243
    BackgroundNormal=0,128,128
    DecorationFocus=0,107,107
    DecorationHover=0,117,117
    ForegroundActive=78,81,172
    ForegroundInactive=186,192,200
    ForegroundLink=0,121,181
    ForegroundNegative=150,75,112
    ForegroundNeutral=0,121,181
    ForegroundNormal=254,254,254
    ForegroundPositive=0,170,127
    ForegroundVisited=170,85,255

    [Colors:Tooltip]
    BackgroundAlternate=28,32,47
    BackgroundNormal=31,36,52
    DecorationFocus=0,107,107
    DecorationHover=0,117,117
    ForegroundActive=78,81,172
    ForegroundInactive=139,145,157
    ForegroundLink=0,121,181
    ForegroundNegative=150,75,112
    ForegroundNeutral=0,121,181
    ForegroundNormal=211,218,227
    ForegroundPositive=0,170,127
    ForegroundVisited=170,85,255

    [Colors:View]
    BackgroundAlternate=31,35,51
    BackgroundNormal=23,27,39
    DecorationFocus=0,107,107
    DecorationHover=0,117,117
    ForegroundActive=78,81,172
    ForegroundInactive=139,145,157
    ForegroundLink=0,121,181
    ForegroundNegative=150,75,112
    ForegroundNeutral=0,121,181
    ForegroundNormal=211,218,227
    ForegroundPositive=0,170,127
    ForegroundVisited=170,85,255

    [Colors:Window]
    BackgroundAlternate=28,32,47
    BackgroundNormal=28,32,47
    DecorationFocus=0,107,107
    DecorationHover=0,117,117
    ForegroundActive=78,81,172
    ForegroundInactive=139,145,157
    ForegroundLink=0,121,181
    ForegroundNegative=150,75,112
    ForegroundNeutral=0,121,181
    ForegroundNormal=211,218,227
    ForegroundPositive=0,170,127
    ForegroundVisited=170,85,255

    [General]
    ColorScheme=GradientDarkColorScheme
    Name=Gradient-Dark-ColorScheme
    shadeSortColumn=true

    [KDE]
    contrast=4

    [WM]
    activeBackground=28,32,47
    activeBlend=28,32,47
    activeForeground=211,218,227
    inactiveBackground=34,39,57
    inactiveBlend=28,32,47
    inactiveForeground=141,147,159
  '';

}
