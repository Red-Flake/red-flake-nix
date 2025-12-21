# bloodhound-quickwin-overlay.nix
# https://github.com/Red-Flake/bloodhound-quickwin

_self: super:

let
  lib = super.lib;
  python313 = super.python313;
  python313Packages = super.python313Packages;
  fetchFromGitHub = super.fetchFromGitHub;

  pansi = super.python313Packages.buildPythonPackage rec {
    pname = "pansi";
    version = "2024.11.0"; # Use the appropriate version

    pyproject = true;
    build-system = with python313Packages; [
      setuptools # Required for setup.py
    ];

    src = super.fetchPypi {
      inherit pname version;
      sha256 = "018186294f012ae48e207d9446b1bd22b0f2ebb2de60a6c4fb079abfacdf4a37";
    };

    propagatedBuildInputs = with super.python313Packages; [
      pillow
    ];
  };

  interchange = super.python313Packages.buildPythonPackage rec {
    pname = "interchange";
    version = "2021.0.4"; # Use the appropriate version

    pyproject = true;
    build-system = with python313Packages; [
      setuptools # Required for setup.py
    ];

    src = super.fetchPypi {
      inherit pname version;
      sha256 = "6791d1b34621e990035fe75d808523172340d80ade1b50412226820184199550";
    };

    propagatedBuildInputs = with super.python313Packages; [
      pytz
      six
    ];
  };

  py2neo = super.python313Packages.buildPythonPackage rec {
    pname = "py2neo";
    version = "2021.2.4"; # Correct version

    pyproject = true;
    build-system = with python313Packages; [
      setuptools # Required for setup.py
    ];

    src = super.fetchPypi {
      inherit pname version;
      sha256 = "sha256-Syc3/Nn9jYK1foVt5O2gBSgcnPB0HJieUlJnjwUD934=";
    };

    propagatedBuildInputs = with super.python313Packages; [
      certifi
      chardet
      urllib3
      idna
      monotonic
      interchange
      pygments
      pansi
    ];

    meta = with lib; {
      description = "Python client library and toolkit for working with Neo4j";
      license = lib.licenses.asl20;
      homepage = "https://github.com/technige/py2neo";
    };
  };

in
{
  bloodhound-quickwin = super.stdenv.mkDerivation rec {
    pname = "bloodhound-quickwin";
    version = "unstable-2024-11-12"; # Use the date as version

    pyproject = true;
    build-system = with python313Packages; [
      setuptools # Required for setup.py
    ];

    src = fetchFromGitHub {
      owner = "Red-Flake";
      repo = "bloodhound-quickwin";
      rev = "463b0f967e8d878d995a5daa534578ba167466ca"; # (commit hash)
      sha256 = "sha256-o0gKoUl62Y8VLydcb6EuPosNAXSaN0NFGdhOwGYtxsw="; # (nix-prefetch-url --unpack https://github.com/Red-Flake/bloodhound-quickwin/archive/463b0f967e8d878d995a5daa534578ba167466ca.tar.gz)
    };

    nativeBuildInputs = [
      python313Packages.setuptools
    ];

    # Use python3.withPackages to create the Python environment
    buildInputs = [
      (python313.withPackages (ps: with ps; [
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
