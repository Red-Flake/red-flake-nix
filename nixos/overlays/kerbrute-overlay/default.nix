# kerbrute-overlay.nix
self: super:

{
  kerbrute = super.stdenv.mkDerivation rec {
    pname = "kerbrute";
    version = "1.0.3";

    src = super.fetchurl {
      url = "https://github.com/ropnop/kerbrute/releases/download/v${version}/kerbrute_linux_amd64";
      sha256 = "sha256-cQqdJlPIvTaJ5FF3jaudrsDeTEx1+QB4jM8j7yVLEio="; # Replace this with the correct hash
    };

    # Skip unpackPhase since there's nothing to unpack
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      install -m755 $src $out/bin/kerbrute
    '';

    meta = with super.lib; {
      description = "A tool to perform Kerberos brute force attacks";
      homepage = "https://github.com/ropnop/kerbrute";
      license = licenses.asl20;
      maintainers = with maintainers; [ lib.maintainers.Mag1cByt3s ];
      platforms = platforms.linux;
    };
  };
}
