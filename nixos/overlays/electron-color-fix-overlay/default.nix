# Fix bright/oversaturated colors on Wayland with wide-gamut displays
# Wraps Electron apps with --disable-features=WaylandWpColorManagerV1
# This fixes buggy Wayland color management protocol implementation
# that causes color issues with Intel Mesa Xe driver
#
# See: https://community.brave.app/t/washed-out-colors-when-hardware-acceleration-is-enabled/643668

_final: prev: {
  vesktop = prev.vesktop.overrideAttrs (oldAttrs: {
    postFixup = (oldAttrs.postFixup or "") + ''
      # Nixpkgs' Electron wrapper may enable speech-dispatcher by default via
      # $NIXOS_SPEECH which can lead to SIGTRAP coredumps in Electron's speech
      # path on some setups. Force-disable it for Vesktop.
      if [ -f "$out/bin/.vesktop-wrapped" ]; then
        substituteInPlace "$out/bin/.vesktop-wrapped" \
          --replace-fail "--enable-speech-dispatcher" ""
      fi
      wrapProgram $out/bin/vesktop \
        --set NIXOS_SPEECH False \
        --add-flags "--disable-features=WaylandWpColorManagerV1 --disable-speech-api --disable-speech-synthesis-api"
    '';
  });
}
