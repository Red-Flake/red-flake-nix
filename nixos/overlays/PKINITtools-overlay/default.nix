# PKINITtools-overlay.nix

self: super:
let
  lib = super.lib;
  stdenv = super.stdenv;
  fetchFromGitHub = super.fetchFromGitHub;
  python312 = super.python312;
  python312Packages = super.python312Packages;
in
{
  pkinittools = stdenv.mkDerivation rec {
    pname = "pkinittools";
    version = "1.0.0";

    src = fetchFromGitHub {
      owner = "dirkjanm";
      repo = "PKINITtools";
      rev = "0f0cfa542b0348609ad494713e84744234b2d3b0";
      sha256 = "sha256-9aKcSe12jsCrjdqcH3w3/T3+DIce2KW08ukSRf5F+hE=";
    };

    # Use setuptools to properly install the package and create entry points
    buildInputs = [
      (super.python312.withPackages (ps: with ps; [
        impacket
        minikerberos
        oscrypto
        pyasn1
      ]))
    ];

    installPhase = ''
      mkdir -p $out/bin
      
      cp $src/getnthash.py $out/bin/
      cp $src/gets4uticket.py $out/bin/
      cp $src/gettgtpkinit.py $out/bin/
      ln -s $out/bin/getnthash.py $out/bin/getnthash
      ln -s $out/bin/gets4uticket.py $out/bin/gets4uticket
      ln -s $out/bin/gettgtpkinit.py $out/bin/gettgtpkinit
      chmod +x $out/bin/getnthash.py
      chmod +x $out/bin/getnthash
      chmod +x $out/bin/gets4uticket.py
      chmod +x $out/bin/gets4uticket
      chmod +x $out/bin/gettgtpkinit.py
      chmod +x $out/bin/gettgtpkinit
    '';

    meta = with lib; {
      description = "PKINITtools for working with Kerberos PKINIT operations";
      homepage = "https://github.com/dirkjanm/PKINITtools";
      license = licenses.mit;
      maintainers = [ maintainers.Mag1cByt3s ];
    };
  };
}
