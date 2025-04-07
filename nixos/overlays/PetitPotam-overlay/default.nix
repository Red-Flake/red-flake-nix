# PetitPotam-overlay.nix

self: super: let
  lib = super.lib;
  stdenv = super.stdenv;
  fetchFromGitHub = super.fetchFromGitHub;
  python312 = super.python312;
  python312Packages = super.python312Packages;
in {
  petitpotam = stdenv.mkDerivation rec {
    pname = "petitpotam";
    version = "1.0.0";

    src = fetchFromGitHub {
      owner = "topotam";
      repo = "PetitPotam";
      rev = "c5d5221dc5e6aac3bc7de97a34fa8d89c2f1900b";
      sha256 = "sha256-eaNnz/61gnBYJiyf4tpdRRTT0mYtRcafgFeUaVoucjY=";
    };

    # Use setuptools to properly install the package and create entry points
    buildInputs = [
      (python312.withPackages (ps: with ps; [ impacket ]))
    ];

    installPhase = ''
      mkdir -p $out/bin
      # Install the script as both with and without .py extension.
      cp $src/PetitPotam.py $out/bin/PetitPotam.py

      # Fix the SyntaxWarning by marking the banner as a raw string literal.
      substituteInPlace $out/bin/PetitPotam.py \
        --replace "show_banner = '''" "show_banner = r'''"

      ln -s $out/bin/PetitPotam.py $out/bin/PetitPotam
      chmod +x $out/bin/PetitPotam.py $out/bin/PetitPotam
    '';

    meta = with lib; {
      description = "PetitPotam exploit tool for Active Directory (impacket based)";
      homepage = "https://github.com/topotam/PetitPotam";
      maintainers = [ maintainers.Mag1cByt3s ];
    };
  };
}
