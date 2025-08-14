# dehashed-overlay.nix
self: super:

let
  lib = super.lib;
  python = super.python313;
  pythonPackages = super.python313Packages;
in
{
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
      fake-useragent
      certifi
      charset-normalizer
      idna
      requests
      soupsieve
      urllib3
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
      license = licenses.asl20;
      maintainers = [ lib.maintainers.Mag1cByt3s ];
    };
  };
}