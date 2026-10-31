# Ghostty in Red Flake Noir. ghostty.nix is shared with other users, so the
# rice only overrides individual settings here.
# Starship and fastfetch use named ANSI colors, so they pick up this palette
# without changes of their own.
{ lib, ricePalette, ... }:
let
  p = ricePalette;
in
{
  programs.ghostty = {
    themes.red-flake-noir = {
      # Same as the title bar (Header color), so window and frame read as one
      background = p.mantle;
      foreground = p.text;
      cursor-color = p.crimsonBright;
      cursor-text = p.mantle;
      selection-background = p.crimsonDeep;
      selection-foreground = p.text;
      palette = [
        "0=${p.surface}"
        "1=${p.crimson}"
        "2=${p.green}"
        "3=${p.gold}"
        "4=${p.blue}"
        "5=${p.violet}"
        "6=${p.cyan}"
        "7=${p.subtext}"
        "8=${p.dim}"
        "9=${p.crimsonBright}"
        "10=#b5e08a"
        "11=#ffc97a"
        "12=#9ab8ff"
        "13=#d9a8ff"
        "14=#7ae6d3"
        "15=${p.text}"
      ];
    };

    settings = {
      theme = lib.mkForce "red-flake-noir";
      font-family = lib.mkForce "Maple Mono NF";
      font-size = lib.mkForce 13;
      font-feature = [ "calt" "liga" ];

      # Opaque on purpose: text is easier to read than on a translucent
      # background (no background-opacity / background-blur here)

      window-padding-x = 14;
      window-padding-y = 10;
      window-padding-balance = true;

      # No progress strip at the top of the terminal (programs like Claude
      # Code report progress via OSC 9;4; it sat right under the title bar)
      progress-style = false;
      unfocused-split-opacity = 0.85;
    };
  };
}
