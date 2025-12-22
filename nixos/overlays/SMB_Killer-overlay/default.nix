# SMB_Killer-overlay.nix
# https://github.com/Red-Flake/SMB_Killer

_self: super:

let
  inherit (super) lib;
in
{
  SMB_Killer = super.stdenv.mkDerivation rec {
    pname = "SMB_Killer";
    version = "unstable-2024-10-24"; # Use the date as version

    src = super.fetchFromGitHub {
      owner = "Red-Flake";
      repo = "SMB_Killer";
      rev = "06f1807df0e1cf3f125305d9eeaa1af5005c189c"; # (commit hash)
      sha256 = "11gl3q69zyh04r85bf68p4xzwn8n89pylqr2xv3jjbq2xi3610xk"; # (nix-prefetch-url --unpack https://github.com/Red-Flake/SMB_Killer/archive/65bd1640873f184f05df5276cb0d78f2fc4981fa.tar.gz)
    };

    nativeBuildInputs = [
      super.python3Packages.setuptools
    ];

    # Use python3.withPackages to create the Python environment
    buildInputs = [
      (super.python3.withPackages (ps: with ps; [
        colorama
      ]))
    ];

    # Install SMB_Killer.py as the main script
    installPhase = ''
      mkdir -p $out/bin
      cp SMB_Killer.py $out/bin/SMB_Killer.py
      ln -s $out/bin/SMB_Killer.py $out/bin/SMB_Killer
      ln -s $out/bin/SMB_Killer.py $out/bin/SMB-Killer.py
      ln -s $out/bin/SMB_Killer.py $out/bin/SMB-Killer
      ln -s $out/bin/SMB_Killer.py $out/bin/smb_killer
      ln -s $out/bin/SMB_Killer.py $out/bin/smb_killer.py
      ln -s $out/bin/SMB_Killer.py $out/bin/smb-killer
      ln -s $out/bin/SMB_Killer.py $out/bin/smb-killer.py
      chmod +x $out/bin/*.py
    '';

    meta = with lib; {
      description = "Simple script to extract useful information from the combo BloodHound + Neo4j";
      homepage = "https://github.com/Red-Flake/bloodhound-quickwin";
      license = lib.licenses.gpl3;
      maintainers = with lib.maintainers; [ lib.maintainers.Mag1cByt3s ];
    };
  };
}
