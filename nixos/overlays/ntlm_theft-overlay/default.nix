# ntlm_theft-overlay.nix
self: super:

let
  lib = super.lib;
in
{
  ntlm_theft = super.stdenv.mkDerivation rec {
    pname = "ntlm_theft";
    version = "1.0.0";

    src = super.fetchFromGitHub {
      owner = "Red-Flake";
      repo = "ntlm_theft";
      rev = "7dfcf567f29f5d848b1eda5671037912c3f61d5a"; # Use a specific commit hash or tag for reproducibility
      sha256 = "sha256-0re3pC3bYyAwla5UCyw6PJiylywsEVrjCzTRhlRJrFA="; # Replace with the actual hash after running `nix-build`
    };

    buildInputs = [
      (super.python3.withPackages (ps: with ps; [
        xlsxwriter
      ]))
    ];

    doCheck = false; # No tests are defined in the repository

    postInstall = ''
      wrapProgram $out/bin/ntlm_theft \
        --prefix PYTHONPATH : "$out/${super.python3Packages.python.sitePackages}"
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp -r ntlm_theft.py $out/bin
      mkdir -p $out/share/ntlm_theft/templates
      cp -r templates/* $out/share/ntlm_theft/templates
      sed -i '1s|^#!/usr/bin/env.*|#!/usr/bin/env python3|' $out/bin/ntlm_theft.py
      chmod +x $out/bin/ntlm_theft.py
      ln -s $out/bin/ntlm_theft.py $out/bin/ntlm_theft
    '';

    meta = with lib; {
      description = "A tool for generating multiple types of NTLMv2 hash theft files by Jacob Wilkin (Greenwolf)";
      homepage = "https://github.com/Greenwolf/ntlm_theft";
      license = licenses.gpl3;
      maintainers = with maintainers; [ Greenwolf ];
      platforms = platforms.linux;
    };
  };
}
