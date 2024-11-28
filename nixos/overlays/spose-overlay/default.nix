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
      rev = "978d5f17d85a6eaf2b3647f197eea450751429ef"; # (commit hash)
      sha256 = "0j88gn7mn7bzjka3zi1qspq1i0nl1l5pxwdi17ibxf0wz6k6xidg"; # (nix-prefetch-url --unpack https://github.com/Red-Flake/spose/archive/978d5f17d85a6eaf2b3647f197eea450751429ef.tar.gz)
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
