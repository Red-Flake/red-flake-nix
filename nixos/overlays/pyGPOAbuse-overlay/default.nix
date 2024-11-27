self: super:

let
  lib = super.lib;
in
{
  pyGPOAbuse = super.stdenv.mkDerivation rec {
    pname = "pyGPOAbuse";
    version = "unstable-2024-11-27"; # Use the date as version

    src = super.fetchFromGitHub {
      owner = "Red-Flake";
      repo = "pyGPOAbuse";
      rev = "77c42dd6ef2bed509ff49359429c58aacfcf6f19"; # (commit hash)
      sha256 = "0ar2njrikirblb8jnifdwf9dh14j7y24drp41cfcks2yj8nhdb53"; # (nix-prefetch-url --unpack https://github.com/Red-Flake/pyGPOAbuse/archive/77c42dd6ef2bed509ff49359429c58aacfcf6f19.tar.gz)
    };

    meta = with lib; {
      description = "Partial python implementation of SharpGPOAbuse";
      homepage = "https://github.com/Hackndo/pyGPOAbuse";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ lib.maintainers.Mag1cByt3s ];
    };

    # Use setuptools to properly install the package and create entry points
    buildInputs = [
      (super.python3.withPackages (ps: with ps; [
        msldap
        impacket
      ]))
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp $src/pygpoabuse/* $out/bin/
      ln -s $out/bin/pygpoabuse.py $out/bin/pygpoabuse
      chmod +x $out/bin/pygpoabuse.py
      chmod +x $out/bin/pygpoabuse
    '';
  };
}
