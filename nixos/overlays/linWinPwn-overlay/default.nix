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

  # Fetch tools using URLs
  tools = [
    { name = "windapsearch"; url = "https://github.com/ropnop/go-windapsearch/releases/latest/download/windapsearch-linux-amd64"; sha256 = "sha256-Fau8XiQiFY1ktPYEQklyMJ+3m7U7Wb9aUnsWZi2GNsE="; }
    { name = "kerbrute"; url = "https://github.com/ropnop/kerbrute/releases/latest/download/kerbrute_linux_amd64"; sha256 = "sha256-cQqdJlPIvTaJ5FF3jaudrsDeTEx1+QB4jM8j7yVLEio="; }
    { name = "enum4linux-ng.py"; url = "https://raw.githubusercontent.com/cddmp/enum4linux-ng/master/enum4linux-ng.py"; sha256 = "sha256-l9QpgaEbqa723N1Pe+yAQX2ID46gzU9oySErAr1ZDmU="; }
    { name = "CVE-2022-33679.py"; url = "https://raw.githubusercontent.com/Bdenneu/CVE-2022-33679/main/CVE-2022-33679.py"; sha256 = "sha256-WH/MfVMU3c6jQuq+izdQC/WKBF2eb60V8lz7kZIc4Hw="; }
    { name = "silenthound.py"; url = "https://raw.githubusercontent.com/layer8secure/SilentHound/main/silenthound.py"; sha256 = "sha256-n4PRgsLwFEEOHs7e4GaawPIJpRWgudKQED4SO0Z6FnE="; }
    { name = "targetedKerberoast.py"; url = "https://raw.githubusercontent.com/ShutdownRepo/targetedKerberoast/main/targetedKerberoast.py"; sha256 = "sha256-vINC5oXOAad5I//dNmAxVHpQIVSYnf3APubUpWb9PYs="; }
    { name = "FindUncommonShares.py"; url = "https://raw.githubusercontent.com/p0dalirius/FindUncommonShares/main/FindUncommonShares.py"; sha256 = "sha256-TnXiduIUDU//oXo2E5+Mm+pf2uPE92yY/FwXVcQU5l4="; }
    { name = "ExtractBitlockerKeys.py"; url = "https://raw.githubusercontent.com/p0dalirius/ExtractBitlockerKeys/refs/heads/main/python/ExtractBitlockerKeys.py"; sha256 = "sha256-DJtZgKTuC9JpHKi2nAPHDF1f7YlWWPd+drCiPLQA2eI="; }
    { name = "ldapconsole.py"; url = "https://raw.githubusercontent.com/p0dalirius/ldapconsole/master/ldapconsole.py"; sha256 = "sha256-B32JcGm8PCfR7oCly0O/lZ/3KAJkBWnsPngAcijuKjM="; }
    { name = "pyLDAPmonitor.py"; url = "https://raw.githubusercontent.com/p0dalirius/LDAPmonitor/master/python/pyLDAPmonitor.py"; sha256 = "sha256-FXrCmju4FEYMfqiUms/oILPZIjtn0/vlEWGlXtlpZmk="; }
    { name = "LDAPWordlistHarvester.py"; url = "https://raw.githubusercontent.com/p0dalirius/LDAPWordlistHarvester/main/LDAPWordlistHarvester.py"; sha256 = "sha256-CfMpSOjfKaAXabIUa56+pkOfXXmu+YWm4Esw6+h97qA="; }
    { name = "adalanche"; url = "https://github.com/lkarlslund/Adalanche/releases/latest/download/adalanche-linux-x64-v2024.1.11"; sha256 = "sha256-8A3psJPspjVBSa01KvCu4S5VmS/iluVFsvdKXStZF2c="; }
    { name = "ldapnomnom"; url = "https://github.com/lkarlslund/ldapnomnom/releases/latest/download/ldapnomnom-linux-x64"; sha256 = "sha256-UoJmmCzT7v1LqEumN3r5rB92wFeKp6zpeKNyDRPnXlA="; }
    { name = "aesKrbKeyGen.py"; url = "https://raw.githubusercontent.com/Tw1sm/aesKrbKeyGen/refs/heads/master/aesKrbKeyGen.py"; sha256 = "sha256-0FBenVXbfdQUbz0zPabApE4aqCzOz5OCPqlbocnPVM8="; }
    # Add more tools if needed
  ];

  # Pre-fetch the tools
  fetchTools = builtins.map (tool: super.fetchurl {
    url = tool.url;
    sha256 = tool.sha256;
  }) tools;

  # Define Python packages installed via pipx
  pipxTools = [
    "git+https://github.com/dirkjanm/ldapdomaindump.git"
    "git+https://github.com/Pennyw0rth/NetExec.git"
    "git+https://github.com/fortra/impacket.git"
    "git+https://github.com/dirkjanm/adidnsdump.git"
    "git+https://github.com/zer1t0/certi.git"
    "git+https://github.com/ly4k/Certipy.git"
    "git+https://github.com/dirkjanm/Bloodhound.py.git"
    "git+https://github.com/franc-pentest/ldeep.git"
    "git+https://github.com/garrettfoster13/pre2k.git"
    "git+https://github.com/zblurx/certsync.git"
    "hekatomb"
    "git+https://github.com/blacklanternsecurity/MANSPIDER.git"
    "git+https://github.com/p0dalirius/Coercer.git"
    "git+https://github.com/CravateRouge/bloodyAD.git"
    "git+https://github.com/login-securite/DonPAPI.git"
    "git+https://github.com/p0dalirius/RDWAtool.git"
    "git+https://github.com/almandin/krbjack.git"
    "git+https://github.com/CompassSecurity/mssqlrelay.git"
    "git+https://github.com/CobblePot59/ADcheck.git"
    "git+https://github.com/ajm4n/adPEAS.git"
    "git+https://github.com/oppsec/breads.git"
    "git+https://github.com/p0dalirius/smbclient-ng.git"
    "git+https://github.com/ScorpionesLabs/MSSqlPwner.git"
  ];

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
      super.python3Packages.pip
      super.python3Packages.setuptools
      super.python3Packages.virtualenv
      super.git
    ];

    buildInputs = [
      (super.python3.withPackages (ps: with ps; [
        certipy
        ldapdomaindump
        pycryptodome
        impacket
        pandas
        requests
        xlsxwriter
        colorama
        typer
      ]))
      super.nmap
      super.smbmap
      super.john
      super.swig
      super.openssl
      super.curl
      super.jq
    ];

    installPhase = ''
      mkdir -p $out/bin $out/opt/linWinPwn/scripts

      # Copy main script
      cp linWinPwn.sh $out/bin/linWinPwn
      chmod +x $out/bin/linWinPwn

      # Copy tools
      ${lib.concatStringsSep "\n" (map (tool: "cp ${tool} $out/opt/linWinPwn/scripts/") fetchTools)}

      # Install Python tools
      python3 -m venv $out/opt/linWinPwn/.venv
      source $out/opt/linWinPwn/.venv/bin/activate
      ${lib.concatStringsSep "\n" (map (tool: "pip install ${tool}") pipxTools)}
      deactivate

      chmod +x $out/opt/linWinPwn/scripts/*
    '';

    meta = with lib; {
      description = "Swiss-Army knife for Active Directory Pentesting using Linux";
      homepage = "https://github.com/lefayjey/linWinPwn";
      license = lib.licenses.gpl3Plus;
    };
  };
}
