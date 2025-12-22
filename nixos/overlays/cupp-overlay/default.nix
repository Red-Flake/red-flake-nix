_self: super:

let
  inherit (super) lib;
in
{
  cupp = super.stdenv.mkDerivation rec {
    pname = "cupp";
    version = "3.3.0"; # matches __version__ in cupp.py

    src = super.fetchFromGitHub {
      owner = "Mebus";
      repo = "cupp";
      rev = "56547fd09b87613cb2614feb5b7688907277a65a";
      sha256 = "1np468jlabc6xkffbp2hdbmkhc8ln4nhfdqlh7h1c9pv1a4i8h4y"; # nix-prefetch-url --unpack https://github.com/Mebus/cupp/archive/56547fd09b87613cb2614feb5b7688907277a65a.tar.gz
    };

    # We just copy a script; no build needed
    dontBuild = true;

    nativeBuildInputs = [ super.python3 ];

    installPhase = ''
      mkdir -p $out/bin

      # Rewrite the shebang so it points at Nix’s Python
      sed "1s|.*|#!${super.python3.interpreter} -W ignore::SyntaxWarning|" \
        ${src}/cupp.py > $out/bin/cupp
      chmod +x $out/bin/cupp

      # install the same wrapper as 'cupp.py' as well
      cp $out/bin/cupp $out/bin/cupp.py
      chmod +x $out/bin/cupp.py

      # Include the default config alongside the script
      install -Dm644 ${src}/cupp.cfg $out/bin/cupp.cfg
    '';

    meta = with lib; {
      description = "Common User Passwords Profiler (CUPP)";
      homepage = "https://github.com/Mebus/cupp";
      license = licenses.gpl3;
      maintainers = with maintainers; [ maintainers.Mag1cByt3s ];
    };
  };
}
