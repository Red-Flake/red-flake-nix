self: super:

let
  pkgs = super;

  certipySrc = pkgs.fetchFromGitHub {
    owner = "ly4k";
    repo  = "Certipy";
    rev   = "5.0.2";
    hash  = "sha256-riFhpB8AMDewz7s4d7jKwmezTHFHJrenC3pWKzfAk6Q=";
  };
in {
  python312Packages = pkgs.python312Packages // {
    certipy-ad = pkgs.python312Packages.certipy-ad.overrideAttrs (old: rec {
      version = "5.0.2";
      src     = certipySrc;

      postPatch = ''
        # Loosen strict version pins and fix the bs4 dependency
        substituteInPlace pyproject.toml \
          --replace-quiet 'cryptography~=42.0.8' 'cryptography' \
          --replace-quiet 'pyopenssl~=24.0.0'     'pyopenssl' \
          --replace-quiet 'pycryptodome~=3.22.0'  'pycryptodome' \
          --replace-quiet 'argcomplete~=3.6.2'    'argcomplete' \
          --replace-quiet 'bs4~=0.0.2'  'beautifulsoup4'
      '';

      propagatedBuildInputs = old.propagatedBuildInputs ++ [
        pkgs.python312Packages.beautifulsoup4
        pkgs.python312Packages.httpx
        pkgs.python312Packages.argcomplete
      ];

      # Disable checks
      doCheck    = false;
      checkPhase = "true";
    });
  };
}