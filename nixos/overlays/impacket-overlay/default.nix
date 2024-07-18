# impacket-overlay.nix
final: prev:
# Within the overlay we use a recursive set, though I think we can use `final` as well.
{
  python312 = prev.python312.override {
    # Careful, we're using a different final and prev here!
    packageOverrides = pyfinal: pyprev: {
      impacket-patched = pyprev.impacket.overrideAttrs (oldAttrs: rec {
        dacleditSrc = prev.fetchurl {
          url = "https://raw.githubusercontent.com/ShutdownRepo/impacket/04518279ef663e80195b61d4d864d6e9e8ac5d9f/examples/dacledit.py";
          sha256 = "sha256-24txUlNLSD7ZZs2VV77QgxBrRI/upeBtaWPAvXsoL0A="; # Replace with the correct SHA-256 hash
        };

        msadaGuidsSrc = prev.fetchurl {
          url = "https://raw.githubusercontent.com/ShutdownRepo/impacket/04518279ef663e80195b61d4d864d6e9e8ac5d9f/impacket/msada_guids.py";
          sha256 = "sha256-XAZUOjLi85e9iBYy9/pAkEd8Ks0xbQB7jU33YcHfsjY="; # Replace with the correct SHA-256 hash
        };

        postInstall =
          (oldAttrs.postInstall or "")
          + ''
            cp ${dacleditSrc} $out/bin/dacledit.py
            chmod +x $out/bin/dacledit.py
            cp ${msadaGuidsSrc} $out/lib/python3.12/site-packages/impacket/msada_guids.py
          '';
      });
    };
  };
}