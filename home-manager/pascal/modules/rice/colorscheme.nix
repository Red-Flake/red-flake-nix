# KDE color scheme "Red Flake Noir", generated from palette.nix.
# KDE's GTK integration copies these colors into ~/.config/gtk-{3,4}.0/colors.css,
# so GTK apps follow as well.
{ p }:
let
  c = p.rgb;

  # Foreground/decoration keys shared by every color set
  common = ''
    DecorationFocus=${c p.wine}
    DecorationHover=${c p.folder}
    ForegroundActive=${c p.ember}
    ForegroundInactive=${c p.muted}
    ForegroundLink=${c p.cyan}
    ForegroundNegative=${c p.crimsonBright}
    ForegroundNeutral=${c p.gold}
    ForegroundNormal=${c p.text}
    ForegroundPositive=${c p.green}
    ForegroundVisited=${c p.violet}
  '';

  set = name: bg: alt: ''
    [Colors:${name}]
    BackgroundAlternate=${c alt}
    BackgroundNormal=${c bg}
    ${common}
  '';
in
''
  [ColorEffects:Disabled]
  Color=${c p.surface}
  ColorAmount=0
  ColorEffect=0
  ContrastAmount=0.65
  ContrastEffect=1
  IntensityAmount=0.1
  IntensityEffect=2

  [ColorEffects:Inactive]
  ChangeSelectionColor=true
  Color=${c p.muted}
  ColorAmount=0.025
  ColorEffect=2
  ContrastAmount=0.1
  ContrastEffect=2
  Enable=false
  IntensityAmount=0
  IntensityEffect=0

  ${set "Button" p.surface2 p.overlay}
  ${set "Complementary" p.crust p.surface}
  ${set "Header" p.mantle p.surface}
  ${set "Header][Inactive" p.base p.mantle}
  ${set "Tooltip" p.surface p.surface2}
  ${set "View" p.base "#111117"}
  ${set "Window" p.mantle p.surface}

  [Colors:Selection]
  BackgroundAlternate=${c p.folderBack}
  BackgroundNormal=${c p.wine}
  DecorationFocus=${c p.wine}
  DecorationHover=${c p.folder}
  ForegroundActive=${c p.text}
  ForegroundInactive=${c p.subtext}
  ForegroundLink=${c p.text}
  ForegroundNegative=${c p.text}
  ForegroundNeutral=${c p.gold}
  ForegroundNormal=255,255,255
  ForegroundPositive=${c p.green}
  ForegroundVisited=${c p.violet}

  [General]
  ColorScheme=RedFlakeNoir
  Name=Red Flake Noir
  shadeSortColumn=true

  [KDE]
  contrast=4

  [WM]
  activeBackground=${c p.mantle}
  activeBlend=${c p.mantle}
  activeForeground=${c p.text}
  inactiveBackground=${c p.base}
  inactiveBlend=${c p.base}
  inactiveForeground=${c p.muted}
''
