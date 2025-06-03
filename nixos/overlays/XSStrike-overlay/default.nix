self: super:

let
  lib = super.lib;
in
{
  xssstrike = super.stdenv.mkDerivation rec {
    pname = "XSStrike";
    version = "3.1.6";

    src = super.fetchFromGitHub {
      owner = "s0md3v";
      repo = "XSStrike";
      rev = "3.1.6";
      sha256 = "1fx5x9r0mnq5z7kzl0f15mqf3vrllj7hfypn01z8nq0qk7s1wkg9";  # nix-prefetch-url --unpack https://github.com/s0md3v/XSStrike/archive/refs/tags/3.1.6.tar.gz
    };

    # We just copy a script; no build needed
    dontBuild = true;

    nativeBuildInputs = [ super.python3 ];

    buildInputs = [
      (super.python3.withPackages (ps: with ps; [
        tld
        fuzzywuzzy
        requests
      ]))
    ];

    installPhase = ''
      mkdir -p $out/bin

      # Copy src to $out/bin/
      cp -r $src/* $out/bin/

      # Make xsstrike.py executable
      chmod +x $out/bin/xsstrike.py

      # install the same wrapper as 'xsstrike' as well
      cp $out/bin/xsstrike.py $out/bin/xsstrike
      chmod +x $out/bin/xsstrike
    '';

    meta = with lib; {
      description = "Most advanced XSS scanner";
      homepage    = "https://github.com/s0md3v/XSStrike";
      license     = licenses.gpl3;
      maintainers = with maintainers; [ maintainers.Mag1cByt3s ];
    };
  };
}
