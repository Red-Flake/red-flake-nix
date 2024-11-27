self: super:

let
  lib = super.lib;
in
{
  spose = super.stdenv.mkDerivation rec {
    pname = "spose";
    version = "unstable-2024-11-27"; # Use the date as version

    src = super.fetchFromGitHub {
      owner = "Red-Flake";
      repo = "spose";
      rev = "90673eeb8ccd003cc629648c7bbcb2ef2486592d"; # (commit hash)
      sha256 = "15gkq6cp59a3lbyfi7p78l1yhg64vkmxa9ybywhs4phipn8xwx5h"; # (nix-prefetch-url --unpack https://github.com/Red-Flake/spose/archive/90673eeb8ccd003cc629648c7bbcb2ef2486592d.tar.gz)
    };

    meta = with lib; {
      description = "Squid Pivoting Open Port Scanner";
      homepage = "https://github.com/Red-Flake/spose";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ lib.maintainers.Mag1cByt3s ];
    };

    # Use setuptools to properly install the package and create entry points
    buildInputs = [
      (super.python3.withPackages (ps: with ps; [
        colorama
      ]))
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp $src/spose.py $out/bin/
      ln -s $out/bin/spose.py $out/bin/spose
      chmod +x $out/bin/spose.py
      chmod +x $out/bin/spose
    '';
  };
}
