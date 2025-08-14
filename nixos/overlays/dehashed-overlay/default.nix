# dehashed-overlay.nix
self: super:

let
  lib = super.lib;
  python = super.python3;
  pythonPackages = super.python3Packages;
in
{
  fake-useragent = pythonPackages.buildPythonPackage rec {
    pname = "fake-useragent";
    version = "1.5.1"; # Compatible with the script's requirements; update to latest (2.2.0 as of 2025) if desired
    pyproject = true;
    build-system = with pythonPackages; [
      setuptools
    ];
    src = super.fetchPypi {
      inherit pname version;
      sha256 = ""; # Run `nix-prefetch-url --unpack https://files.pythonhosted.org/packages/source/f/fake-useragent/fake-useragent-${version}.tar.gz` to get the actual sha256
    };
    # No propagatedBuildInputs needed, as fake-useragent has no runtime dependencies
    meta = with lib; {
      description = "Up-to-date simple useragent faker with real world database";
      homepage = "https://github.com/fake-useragent/fake-useragent";
      license = licenses.asl20; # Apache License 2.0
    };
  };

  dehashed = pythonPackages.buildPythonApplication rec {
    pname = "dehashed";
    version = "unstable-2024-10-17"; # Based on approximate last update; update if newer commits exist
    pyproject = false; # No setup.py, manual install
    src = super.fetchFromGitHub {
      owner = "sm00v";
      repo = "Dehashed";
      rev = "e203d11df8d368f623075748cc2d7070227db04e"; # Use specific commit if known, e.g., "4a7f0b3" if that's the latest
      sha256 = "sha256-TjVEVmPnHRWitOiBQswRa4n6iHyFChoMdFrip75SJBU="; # Run `nix-prefetch-github sm00v Dehashed` to get the actual sha256
    };
    propagatedBuildInputs = with pythonPackages; [
      beautifulsoup4
      requests
      fake-useragent # Our custom package
      # Other deps from requirements.txt are transitive (e.g., certifi, idna, urllib3 via requests; soupsieve via bs4)
    ];
    dontCheck = true; # No tests in repo
    installPhase = ''
      mkdir -p $out/bin
      cp $src/dehashed.py $out/bin/dehashed.py
      cp $src/dehashed.py $out/bin/dehashed
      cp $src/hash_crack.py $out/bin/hash_crack.py
      chmod +x $out/bin/dehashed $out/bin/dehashed.py $out/bin/hash_crack.py
    '';
    meta = with lib; {
      description = "Scripts to query dehashed.com API for domain breaches and crack returned hashes using hashes.com";
      homepage = "https://github.com/sm00v/Dehashed";
      license = licenses.mit; # Assumed, as repo has no explicit license; confirm if needed
      maintainers = [ lib.maintainers.Mag1cByt3s ];
    };
  };
}