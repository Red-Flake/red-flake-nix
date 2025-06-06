# impacket-overlay.nix
final: prev: {
  python312 = prev.python312.override {
    packageOverrides = pyfinal: pyprev: {
      impacket-patched = pyprev.impacket.overrideAttrs (oldAttrs: rec {
        dacleditSrc = final.fetchurl {
          url = "https://raw.githubusercontent.com/ShutdownRepo/impacket/04518279ef663e80195b61d4d864d6e9e8ac5d9f/examples/dacledit.py";
          sha256 = "sha256-24txUlNLSD7ZZs2VV77QgxBrRI/upeBtaWPAvXsoL0A=";
        };

        msadaGuidsSrc = final.fetchurl {
          url = "https://raw.githubusercontent.com/ShutdownRepo/impacket/04518279ef663e80195b61d4d864d6e9e8ac5d9f/impacket/msada_guids.py";
          sha256 = "sha256-XAZUOjLi85e9iBYy9/pAkEd8Ks0xbQB7jU33YcHfsjY=";
        };

        # Add OpenSSL configuration
        openssl_conf = final.writeText "openssl.conf" ''
          openssl_conf = openssl_init

          [openssl_init]
          providers = provider_sect

          [provider_sect]
          default = default_sect
          legacy = legacy_sect

          [default_sect]
          activate = 1

          [legacy_sect]
          activate = 1
        '';

        postInstall =
          (oldAttrs.postInstall or "")
          + ''
            cp ${dacleditSrc} $out/bin/dacledit.py
            chmod +x $out/bin/dacledit.py
            cp ${msadaGuidsSrc} $out/lib/python3.12/site-packages/impacket/msada_guids.py
          '';

        postFixup = ''
          ${oldAttrs.postFixup or ""}
          wrapProgram $out/bin/mssqlclient.py \
            --prefix OPENSSL_CONF : ${openssl_conf}
          wrapProgram $out/bin/owneredit.py \
            --prefix OPENSSL_CONF : ${openssl_conf}
          wrapProgram $out/bin/dacledit.py \
            --prefix OPENSSL_CONF : ${openssl_conf}
          wrapProgram $out/bin/rbcd.py \
            --prefix OPENSSL_CONF : ${openssl_conf}
        '';
      });
    };
  };

  # override python312Packages to follow the new python312
  python312Packages = final.python312.pkgs;
}
