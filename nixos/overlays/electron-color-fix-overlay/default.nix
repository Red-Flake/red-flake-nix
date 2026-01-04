# Fix bright/oversaturated colors on Wayland with wide-gamut displays
# Wraps Electron apps with --disable-features=WaylandWpColorManagerV1
# This fixes buggy Wayland color management protocol implementation
# that causes color issues with Intel Mesa Xe driver
#
# See: https://community.brave.app/t/washed-out-colors-when-hardware-acceleration-is-enabled/643668

_final: prev: {
  vesktop = prev.vesktop.overrideAttrs (oldAttrs: {
    postFixup = (oldAttrs.postFixup or "") + ''
      wrapProgram $out/bin/vesktop \
        --add-flags "--disable-features=WaylandWpColorManagerV1"
    '';
  });
}
