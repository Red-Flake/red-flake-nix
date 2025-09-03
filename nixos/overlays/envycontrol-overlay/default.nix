# overlays/envycontrol.nix
self: super:

let
  lib = super.lib;
in
{
  envycontrol = super.python3Packages.buildPythonApplication rec {
    pname = "envycontrol";
    version = "3.5.2";

    src = super.fetchFromGitHub {
      owner = "bayasdev";
      repo = "envycontrol";
      rev = "v${version}";
      sha256 = "sha256-FZMkYHUAA3keV7OSqzEIu0k1rdgDS0VP3nPBLBzbaeM=";
    };

    format = "setuptools";

    meta = with lib; {
      description = "Easy GPU switching for Nvidia Optimus laptops under Linux";
      homepage = "https://github.com/bayasdev/envycontrol";
      license = licenses.mit;
      maintainers = [ ];
      platforms = platforms.linux;
      mainProgram = "envycontrol";
    };
  };
}
