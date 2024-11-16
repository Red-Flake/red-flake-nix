# linWinPwn-overlay.nix
self: super:

let
  lib = super.lib;

  # Define custom Python dependencies
  certipy = super.python3Packages.buildPythonPackage rec {
    pname = "certipy-ad";
    version = "4.8.2";
    src = super.fetchPypi {
      inherit pname version;
      sha256 = "sha256-A6p+iY7/KUbDJJT4LC8Vavu8lm/RV+WZeAqxnWOOr1A=";
    };
    propagatedBuildInputs = with super.python3Packages; [
      pycryptodome requests
    ];
    meta = with lib; {
      description = "Active Directory Certificate Services enumeration and abuse";
      homepage = "https://github.com/ly4k/Certipy";
      license = lib.licenses.gpl3Plus;
    };
  };

  # Pre-fetch external resources
  windapsearch = super.fetchurl {
    url = "https://github.com/ropnop/go-windapsearch/releases/latest/download/windapsearch-linux-amd64";
    sha256 = "sha256-Fau8XiQiFY1ktPYEQklyMJ+3m7U7Wb9aUnsWZi2GNsE="; # Replace with correct hash
  };

  kerbrute = super.fetchurl {
    url = "https://github.com/ropnop/kerbrute/releases/latest/download/kerbrute_linux_amd64";
    sha256 = "sha256-cQqdJlPIvTaJ5FF3jaudrsDeTEx1+QB4jM8j7yVLEio="; # Replace with correct hash
  };

  enum4linuxNg = super.fetchurl {
    url = "https://raw.githubusercontent.com/cddmp/enum4linux-ng/master/enum4linux-ng.py";
    sha256 = "sha256-l9QpgaEbqa723N1Pe+yAQX2ID46gzU9oySErAr1ZDmU="; # Replace with correct hash
  };

in
{
  linWinPwn = super.stdenv.mkDerivation rec {
    pname = "linWinPwn";
    version = "latest";

    src = super.fetchFromGitHub {
      owner = "lefayjey";
      repo = "linWinPwn";
      rev = "main";
      sha256 = "sha256-1W9QlgmM91TqHNYXYPlvkfYDFBd2gGoZMYP8z6ASYnU=";
    };

    nativeBuildInputs = [
      super.makeWrapper
      super.unzip
    ];

    buildInputs = [
      (super.python3.withPackages (ps: with ps; [
        certipy
        ldapdomaindump
        pycryptodome
        impacket
        requests
        pandas
      ]))
    ];

    buildPhase = "true"; # No build required

    installPhase = ''
      mkdir -p $out/bin $out/opt/linWinPwn/scripts

      # Ensure linWinPwn.sh exists and copy it
      if [ -f ./linWinPwn.sh ]; then
        cp ./linWinPwn.sh $out/bin/linWinPwn
        chmod +x $out/bin/linWinPwn
      else
        echo "Error: linWinPwn.sh not found!" >&2
        exit 1
      fi

      # Copy pre-fetched resources
      cp ${windapsearch} $out/opt/linWinPwn/scripts/windapsearch
      cp ${kerbrute} $out/opt/linWinPwn/scripts/kerbrute
      cp ${enum4linuxNg} $out/opt/linWinPwn/scripts/enum4linux-ng.py

      # Set executable permissions
      chmod +x $out/opt/linWinPwn/scripts/*

      # Wrap the main script to set the PATH and scripts_dir
      wrapProgram $out/bin/linWinPwn \
        --prefix PATH ":" "$out/bin:$out/opt/linWinPwn/scripts" \
        --set scripts_dir "$out/opt/linWinPwn/scripts"
    '';

    meta = with lib; {
      description = "Swiss-Army knife for Active Directory Pentesting using Linux";
      homepage = "https://github.com/lefayjey/linWinPwn";
      license = lib.licenses.gpl3Plus;
      maintainers = with lib.maintainers; [ lib.maintainers.Mag1cByt3s ];
    };
  };
}
