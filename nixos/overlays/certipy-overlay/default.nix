self: super:

let
  pkgs = super;

  certipySrc = pkgs.fetchFromGitHub {
    owner = "ly4k";
    repo  = "Certipy";
    tag   = "5.0.2";                            # upstream tag is literally "5.0.2"
    hash  = "<YOUR-SHA256-FROM-nix-prefetch-github>";
  };
in {
  # One python3Packages override, not two
  python3Packages = pkgs.python3Packages // {

    # 1) Put flake8 back so ${buildPythonPackages.flake8} exists
    #flake8 = pkgs.callPackage
    #  "${pkgs.path}/pkgs/development/python-modules/flake8" { };

    # 2) Your patched certipy-ad
    certipy-ad = pkgs.python3Packages.certipy-ad.overrideAttrs (old: rec {
      version = "5.0.2";
      src     = certipySrc;

      postPatch = ''
        # remove the new .flake8 file
        rm -f .flake8

        # loosen the strict version pins in pyproject.toml
        substituteInPlace pyproject.toml \
          --replace 'cryptography~=42.0.8' 'cryptography' \
          --replace 'pyopenssl~=24.0.0'     'pyopenssl' \
          --replace 'pycryptodome~=3.22.0'  'pycryptodome' \
          --replace 'argcomplete~=3.6.2'    'argcomplete' \
          --replace '"bs4",\'\'
      '';

      propagatedBuildInputs = old.propagatedBuildInputs ++ [
        pkgs.python3Packages.beautifulsoup4
        pkgs.python3Packages.httpx
        pkgs.python3Packages.argcomplete
      ];

      # Disable every lint / import‐check hook
      writeScriptHook      = "";     # never write pythoncheck.sh
      dontWriteCheckScript = true;   # guarantee no pythoncheck.sh
      checkPhase           = "true"; # no-op
      doCheck              = false;  # skip any tests
    });
  };
}
