# Reduce Ghostty log spam in journald.
#
# Ghostty warns loudly when GTK reports `gtk-xft-dpi` as unset/invalid (common on
# some non-GNOME Wayland setups). This is harmless (Ghostty falls back to
# 96 DPI), but it can spam journald.
_final: prev:
{
  ghostty = prev.ghostty.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      ./suppress-gtk-xft-dpi-warning.patch
      ./suppress-more-journald-noise.patch
    ];
  });
}
