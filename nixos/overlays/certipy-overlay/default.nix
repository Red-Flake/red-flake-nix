_self: super:

let
  pkgs = super;

  version = "5.0.3";

  certipySrc = pkgs.fetchFromGitHub {
    owner = "ly4k";
    repo = "Certipy";
    rev = version;
    hash = "sha256-riFhpB8AMDewz7s4d7jKwmezTHFHJrenC3pWKzfAk6Q=";
  };
in
{
  python314Packages = pkgs.python314Packages // {
    certipy-ad = pkgs.python314Packages.certipy-ad.overrideAttrs (old: rec {
      inherit version;
      src = certipySrc;

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
        pkgs.python314Packages.beautifulsoup4
        pkgs.python314Packages.httpx
        pkgs.python314Packages.argcomplete
      ];

      # Disable checks
      doCheck = false;
      checkPhase = "true";
    });
  };
}
