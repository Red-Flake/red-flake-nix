final: prev:

let
  version = "1.5.43";
  serverSrc = final.fetchurl {
    url = "https://github.com/BishopFox/sliver/releases/download/v${version}/sliver-server_linux";
    sha256 = "sha256-iHO0XRru8Yg6j4DgqlDeRf5sXwtub2jLXjZb9ygcSz8=";
  };
  clientSrc = final.fetchurl {
    url = "https://github.com/BishopFox/sliver/releases/download/v${version}/sliver-client_linux";
    sha256 = "sha256-30m/U3RyU8OC3lRP308v0XtYaswXy4HPTEFoxTUyJgk=";
  };
in {
  sliver = final.stdenv.mkDerivation {
    pname = "sliver";
    inherit version;
    nativeBuildInputs = [ final.autoPatchelfHook ];
    buildInputs = [ ];  # Add dependencies if needed
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/bin
      cp ${serverSrc} $out/bin/sliver-server
      cp ${clientSrc} $out/bin/sliver-client
      chmod +x $out/bin/sliver-server $out/bin/sliver-client
    '';
  };
}