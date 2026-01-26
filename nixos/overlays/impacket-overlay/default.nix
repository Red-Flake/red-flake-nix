# impacket-overlay.nix
final: prev: {
  python314 = prev.python314.override {
    packageOverrides = _pyfinal: pyprev: {
      impacket = pyprev.impacket.overrideAttrs (oldAttrs: rec {
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

  # override python314Packages to follow the new python314
  python314Packages = final.python314.pkgs;
}
