# linWinPwn-overlay.nix
self: super:

let
  # Include poetry2nix
  #poetry2nix = import "${inputs.poetry2nix.outPath}";

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

  # Define Python packages
  manspider = super.poetry2nix.mkPoetryApplication {
    projectDir = super.fetchFromGitHub {
      owner = "blacklanternsecurity";
      repo = "MANSPIDER";
      rev = "master";
      sha256 = "sha256-iUANLzLrdHfGWKsCOQ5DJhvvItqXTJd8akzaPqrWuMM";
    };
  };

  mssqlrelay = super.python3Packages.buildPythonPackage rec {
    pname = "mssqlrelay";
    version = "latest";
    src = super.fetchFromGitHub {
      owner = "CompassSecurity";
      repo = "mssqlrelay";
      rev = "main";
      sha256 = "sha256-4DtMgu3Gq6J+btbSf68/FddBtp8Gen13F21ugKyNZ7A="; # Fetch and replace with actual hash
    };
    propagatedBuildInputs = with super.python3Packages; [ requests impacket ];
    meta = {
      description = "MS SQL relay utility for pentesting.";
      homepage = "https://github.com/CompassSecurity/mssqlrelay";
      license = super.lib.licenses.gpl2;
    };
  };

  adcheck = super.python3Packages.buildPythonPackage rec {
    pname = "adcheck";
    version = "latest";

    src = super.fetchFromGitHub {
      owner = "CobblePot59";
      repo = "ADcheck";
      rev = "main";
      sha256 = "sha256-Qn7goamHlcr1cTsEsp8TNCialO1DFD4js2jmYgBBhdg="; # Replace with the correct hash
    };

    # Use 'other' for non-setuptools-based projects
    format = "other";

    propagatedBuildInputs = with super.python3Packages; [ requests ldap3 ];

    # Custom install phase to handle the structure
    installPhase = ''
      mkdir -p $out/bin
      cp -r . $out/bin/
      ln -s $out/bin/run_adcheck.py $out/bin/adcheck
      chmod +x $out/bin/run_adcheck.py
      chmod +x $out/bin/adcheck
    '';

    meta = {
      description = "Active Directory checker tool.";
      homepage = "https://github.com/CobblePot59/ADcheck";
      license = super.lib.licenses.mit;
    };
  };

  adpeas = super.python3Packages.buildPythonPackage rec {
    pname = "adPEAS";
    version = "latest";
    src = super.fetchFromGitHub {
      owner = "ajm4n";
      repo = "adPEAS";
      rev = "main";
      sha256 = "sha256-ONowqHCkT4JRQtj2nwb+VRLXcTBviRaw3dIMEqwTDcw="; # Fetch and replace with actual hash
    };
    propagatedBuildInputs = with super.python3Packages; [ ldap3 pandas ];
    meta = {
      description = "Active Directory post-exploitation enumeration tool.";
      homepage = "https://github.com/ajm4n/adPEAS";
      license = super.lib.licenses.asl20;
    };
  };

  mssqlpwner = super.poetry2nix.mkPoetryApplication {
    projectDir = super.fetchFromGitHub {
      owner = "ScorpionesLabs";
      repo = "MSSqlPwner";
      rev = "main";
      hash = "sha256-pMOsoGycs81htwcFN8JfbMMoSIMts4nyek62njpjTug";
    };
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
      super.python3Packages.pip
      super.python3Packages.setuptools
      super.python3Packages.virtualenv
      super.git
    ];

    buildInputs = [
      (super.python3.withPackages (ps: with ps; [
        mssqlrelay
        adcheck
        adpeas
        ldapdomaindump
        pycryptodome
        impacket
        pandas
        requests
        xlsxwriter
        colorama
        typer
        bloodhound-py
        bloodyad
      ]))
      mssqlpwner
      super.nmap
      super.smbmap
      super.john
      super.swig
      super.openssl
      super.curl
      super.jq
      super.netexec
      super.adidnsdump
      super.certipy
      super.ldeep
      super.pre2k
      super.certsync
      super.coercer
      super.donpapi
      super.rdwatool
      super.krbjack
      super.breads-ad
      super.smbclient-ng
      super.hekatomb
    ];

    installPhase = ''
      mkdir -p $out/bin $out/opt/linWinPwn/scripts

      # Copy main linWinPwn script to $out/bin
      cp linWinPwn.sh $out/bin/linWinPwn
      chmod +x $out/bin/linWinPwn

      # Copy tools to the scripts directory
      ${super.lib.concatStringsSep "\n" (map (tool: ''
        cp ${tool} $out/bin/${tool.name}
        chmod +x $out/bin/${tool.name}
      '') fetchTools)}

      runHook postInstall
    '';

    postInstall = ''
      # Wrap the main linWinPwn script
      wrapProgram $out/bin/linWinPwn \
        --set PATH "${super.lib.makeBinPath ([
          super.which
          super.iproute2
          super.gnused
          super.python3
          mssqlrelay
          adcheck
          adpeas
          mssqlpwner
          # manspider: manspider broken ???
          adcheck
          super.ldapdomaindump
          super.python3Packages.pycryptodome
          super.python3Packages.impacket
          super.python3Packages.pandas
          super.python3Packages.requests
          super.bloodhound-py
          super.python3Packages.bloodyad
          super.nmap
          super.smbmap
          super.john
          super.swig
          super.openssl
          super.curl
          super.jq
          super.netexec
          super.adidnsdump
          super.certipy
          super.ldeep
          super.pre2k
          super.certsync
          super.coercer
          super.donpapi
          super.rdwatool
          super.krbjack
          super.breads-ad
          super.smbclient-ng
          super.hekatomb
        ] ++ fetchTools)}"
    '';

    meta = {
      description = "Swiss-Army knife for Active Directory Pentesting using Linux";
      homepage = "https://github.com/lefayjey/linWinPwn";
      license = super.lib.licenses.gpl3Plus;
    };
  };
}