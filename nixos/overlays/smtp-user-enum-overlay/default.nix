# smtp-user-enum-overlay.nix

self: super:

let
  lib = super.lib;
in
{
  smtp-user-enum = super.stdenv.mkDerivation rec {
    pname = "smtp-user-enum";
    version = "unstable-2023-04-03"; # Use the date as version

    src = super.fetchFromGitHub {
      owner = "cytopia";
      repo = "smtp-user-enum";
      rev = "758d60268733b00d9b18d510ede3dabd1fab3294"; # (commit hash)
      sha256 = "sha256-2GI//nv87H2zDkkgjAHSx2Zm2Sk0EpxmXQAN+I1K65I="; # Replace with actual hash
    };

    nativeBuildInputs = [
      super.python3Packages.setuptools
    ];

    buildInputs = [
      (super.python3.withPackages (ps: with ps; [
        dnspython
      ]))
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp smtp-user-enum $out/bin/smtp-user-enum
      chmod +x $out/bin/smtp-user-enum
    '';

    meta = with lib; {
      description = "SMTP username enumeration tool";
      homepage = "https://github.com/cytopia/smtp-user-enum";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ lib.maintainers.Mag1cByt3s ];
    };
  };
}
