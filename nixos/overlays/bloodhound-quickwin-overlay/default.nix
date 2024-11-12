# bloodhound-quickwin-overlay.nix
# https://github.com/Red-Flake/bloodhound-quickwin

self: super:

let
  lib = super.lib;

  py2neo = super.python3Packages.buildPythonPackage rec {
    pname = "py2neo";
    version = "2021.2.4";  # Correct version

    src = super.fetchPypi {
      inherit pname version;
      sha256 = "sha256-Syc3/Nn9jYK1foVt5O2gBSgcnPB0HJieUlJnjwUD934=";
    };

    propagatedBuildInputs = with super.python3Packages; [
      certifi chardet urllib3 idna
    ];

    meta = with lib; {
      description = "Python client library and toolkit for working with Neo4j";
      license = lib.licenses.asl20;
      homepage = "https://github.com/technige/py2neo";
    };
  };

  interchange = super.python3Packages.buildPythonPackage rec {
    pname = "interchange";
    version = "2021.0.4";  # Use the appropriate version
    src = super.fetchPypi {
      inherit pname version;
      sha256 = "6791d1b34621e990035fe75d808523172340d80ade1b50412226820184199550";
    };
  };

in
{
  bloodhound-quickwin = super.stdenv.mkDerivation rec {
    pname = "bloodhound-quickwin";
    version = "unstable-2024-11-12"; # Use the date as version
    
    src = super.fetchFromGitHub {
      owner = "Red-Flake";
      repo = "bloodhound-quickwin";
      rev = "4be6efc3a1c737deb08b4fcb755d77056fcf7b06"; # (commit hash)
      sha256 = "0bs2fbm0yl4s9b2hnmmqmb5z5gyff4j53s6927nqdb1azfgzhjj3"; # (nix-prefetch-url --unpack https://github.com/Red-Flake/bloodhound-quickwin/archive/4be6efc3a1c737deb08b4fcb755d77056fcf7b06.tar.gz)
    };

    nativeBuildInputs = [
      super.python3Packages.setuptools
    ];

    # Use python3.withPackages to create the Python environment
    buildInputs = [
      (super.python3.withPackages (ps: with ps; [
        py2neo
        interchange
        pycryptodome
        neo4j
        certifi
        chardet
        urllib3
        idna
        prettytable
        monotonic
        packaging
        six
      ]))
    ];

    # Install bhqc.py as the main script
    installPhase = ''
      mkdir -p $out/bin
      cp bhqc.py $out/bin/bhqc.py
      chmod +x $out/bin/bhqc.py
    '';

    meta = with lib; {
      description = "Simple script to extract useful information from the combo BloodHound + Neo4j";
      homepage = "https://github.com/Red-Flake/bloodhound-quickwin";
      license = lib.licenses.gpl3;
      maintainers = with lib.maintainers; [ lib.maintainers.Mag1cByt3s ];
    };
  };
}
