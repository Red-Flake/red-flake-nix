_self: super:

let
  inherit (super) lib;
in
{
  pyGPOAbuse = super.stdenv.mkDerivation rec {
    pname = "pyGPOAbuse";
    version = "unstable-2024-11-27"; # Use the date as version

    src = super.fetchFromGitHub {
      owner = "Red-Flake";
      repo = "pyGPOAbuse";
      rev = "9dc995ea0c7f866ee1d7307f9005ad3216fbaf3f"; # (commit hash)
      sha256 = "1kc5w6l4p3w9mqw66byssz8rgm6hnc1qag42hqsnq6lgyvkz3r7m"; # (nix-prefetch-url --unpack https://github.com/Red-Flake/pyGPOAbuse/archive/9dc995ea0c7f866ee1d7307f9005ad3216fbaf3f.tar.gz)
    };

    meta = with lib; {
      description = "Partial python implementation of SharpGPOAbuse";
      homepage = "https://github.com/Hackndo/pyGPOAbuse";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ lib.maintainers.Mag1cByt3s ];
    };

    # Use setuptools to properly install the package and create entry points
    buildInputs = [
      (super.python312.withPackages (ps: with ps; [
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
