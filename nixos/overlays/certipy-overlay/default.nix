_self: super:

let
  pkgs = super;
  inherit (pkgs) lib;

  version = "5.0.4";

  certipySrc = pkgs.fetchFromGitHub {
    owner = "ly4k";
    repo = "Certipy";
    rev = version;
    hash = "sha256-5STwBpX+8EsgRYMEirvqEhu4oMDs4hf4lDge1ShpKf4=";
  };

  overrideCertipy = pythonPkgs:
    pythonPkgs.certipy-ad.overrideAttrs (old: rec {
      inherit version;
      src = certipySrc;

      postPatch = ''
        # Loosen strict version pins and fix the bs4 dependency
        substituteInPlace pyproject.toml \
          --replace-quiet 'asn1crypto~=1.5.1'     'asn1crypto' \
          --replace-quiet 'cryptography~=42.0.8' 'cryptography' \
          --replace-quiet 'dnspython~=2.7.0'      'dnspython' \
          --replace-quiet 'impacket~=0.13.0'      'impacket' \
          --replace-quiet 'ldap3~=2.9.1'          'ldap3' \
          --replace-quiet 'pyasn1~=0.6.1'         'pyasn1' \
          --replace-quiet 'pyopenssl~=24.0.0'     'pyopenssl' \
          --replace-quiet 'pycryptodome~=3.22.0'  'pycryptodome' \
          --replace-quiet 'argcomplete~=3.6.2'    'argcomplete' \
          --replace-quiet 'requests~=2.32.3'      'requests' \
          --replace-quiet 'httpx~=0.28.1'         'httpx' \
          --replace-quiet 'neo4j~=5.28.1'         'neo4j' \
          --replace-quiet 'bs4~=0.0.2'            'beautifulsoup4' \
          --replace-quiet 'beautifulsoup4~=4.13.4' 'beautifulsoup4'
      '';

      propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [
        pythonPkgs.beautifulsoup4
        pythonPkgs.httpx
        pythonPkgs.argcomplete
      ];

      pythonRelaxDeps = (old.pythonRelaxDeps or [ ]) ++ [
        # beautifulsoup4~=4.13.4 not satisfied by version 4.14.3
        "beautifulsoup4"
        "bs4"
      ];

      # Disable checks
      doCheck = false;
      checkPhase = "true";
    });
  patchSet = pythonPkgs:
    pythonPkgs.override {
      overrides = _self: super: {
        certipy-ad = overrideCertipy super;
      };
    };
in
(lib.optionalAttrs (pkgs ? python3Packages) {
  python3Packages = patchSet pkgs.python3Packages;
})
//
(lib.optionalAttrs (pkgs ? python313Packages) {
  python313Packages = patchSet pkgs.python313Packages;
})
  //
(lib.optionalAttrs (pkgs ? python314Packages) {
  python314Packages = patchSet pkgs.python314Packages;
})
