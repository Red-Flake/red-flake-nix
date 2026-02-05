# Reduce Ghostty log spam in journald.
#
# Ghostty warns loudly when GTK leaves `gtk-xft-dpi` unset (common on some
# non-GNOME Wayland setups). This is harmless (Ghostty falls back to 96 DPI),
# but it spams journald.
_final: prev:
{
  ghostty = prev.ghostty.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      ./suppress-gtk-xft-dpi-warning.patch
      ./suppress-osc-warnings.patch
    ];
  });
}
