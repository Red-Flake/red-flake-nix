# Red Flake Noir: the one palette every part of the rice reads from.
# Change a color here and Plasma, GTK, Ghostty, VS Code, Equibop, Firefox
# and the login screen follow on the next rebuild.
{ lib }:
let
  colors = {
    # Surfaces, darkest to lightest
    crust = "#08080b";
    base = "#0b0b0f"; # views, terminal background
    mantle = "#101016"; # windows, title bars
    surface = "#15151c"; # tooltips, cards
    surface2 = "#1c1c25"; # buttons
    overlay = "#22222c"; # hover, alternate rows
    border = "#2e2e3a";

    # Text
    text = "#e6e1e5";
    subtext = "#b8b3bd";
    muted = "#8a8592";
    dim = "#4a4652";

    # Accents
    crimson = "#e0284f"; # main accent
    crimsonBright = "#ff4d6d";
    crimsonDeep = "#a01f34";
    # Muted reds for large surfaces, where full crimson is too loud
    wine = "#9e2b42"; # KDE accent: selections, highlights, focus
    folder = "#7c2636"; # Papirus folder body
    folderBack = "#5a1b28"; # Papirus folder back
    folderInk = "#2a0b12"; # glyphs on folders
    ember = "#ff6b3d";
    gold = "#f5b45e";
    green = "#9ece6a";
    cyan = "#4fd6be";
    blue = "#7aa2f7";
    violet = "#c792ea";
  };

  hexByte = s: lib.fromHexString s;

  # "#e0284f" -> "224,40,79" (the format KDE .colors files use)
  rgb =
    hex:
    let
      h = lib.removePrefix "#" hex;
    in
    lib.concatMapStringsSep "," (i: toString (hexByte (builtins.substring i 2 h))) [ 0 2 4 ];

  # "#e0284f" 0.85 -> "rgba(224,40,79,0.85)" for CSS
  rgba = hex: alpha: "rgba(${rgb hex},${toString alpha})";
in
colors // { inherit rgb rgba; }
