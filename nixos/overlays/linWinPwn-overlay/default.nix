# linWinPwn-overlay.nix
self: super:

let
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
  ];

  # Pre-fetch the tools
  fetchTools = builtins.map (tool: super.fetchurl {
    url = tool.url;
    sha256 = tool.sha256;
  }) tools;

  # Define Python packages
  # Define textract manually
  textract = self.stdenv.mkDerivation rec {
    pname = "textract";
    version = "latest";

    src = super.fetchFromGitHub {
      owner = "tehabstract";
      repo = "textract";
      rev = "0c80ff5727061587442fc5a1886c668d53e8d16d";
      sha256 = "sha256-QypO4ZjmmHQtHKHmVqd5vETifEDo5v6ELx42GeE1N5w=";
    };

    nativeBuildInputs = [
      python3
    ];

    propagatedBuildInputs = with python3Packages; [
      six
      chardet
      xlrd
      lxml
      python-magic
    ];

    installPhase = ''
      mkdir -p $out/lib/${python3.pythonVersion}/site-packages
      cp -r ./* $out/lib/${python3.pythonVersion}/site-packages/
      chmod -R a+rX $out/lib/${python3.pythonVersion}/site-packages
    '';

    meta = {
      description = "Text extraction library for various file formats";
      homepage = "https://github.com/tehabstract/textract";
      license = super.lib.licenses.mit;
    };
  };


  # Define manspider with textract as a built input
  manspider = self.stdenv.mkDerivation rec {
    pname = "manspider";
    version = "1.0.4";

    src = super.fetchFromGitHub {
      owner = "blacklanternsecurity";
      repo = "MANSPIDER";
      rev = "30ce682f1ec521c47596a2bccd20131ab4ca0e4a";
      sha256 = "sha256-iUANLzLrdHfGWKsCOQ5DJhvvItqXTJd8akzaPqrWuMM=";
    };

    nativeBuildInputs = [
      python3
      python3Packages.six
      python3Packages.chardet
      python3Packages.xlrd
      python3Packages.lxml
      python3Packages.python-magic
    ];

    propagatedBuildInputs = with python3Packages; [
      impacket
      textract
    ];

    installPhase = ''
      mkdir -p $out/lib/${python3.pythonVersion}/site-packages $out/bin

      # Copy the MANSPIDER code manually to the site-packages
      cp -r man_spider $out/lib/${python3.pythonVersion}/site-packages/
      chmod -R a+rX $out/lib/${python3.pythonVersion}/site-packages/man_spider

      # Create a wrapper script for the `manspider` CLI
      cat > $out/bin/manspider <<'EOF'
      #!/usr/bin/env python3
      import sys
      from man_spider.manspider import main
      sys.exit(main())
      EOF

      chmod +x $out/bin/manspider
    '';

    meta = {
      description = "Full-featured SMB spider capable of searching file content";
      homepage = "https://github.com/blacklanternsecurity/MANSPIDER";
      license = super.lib.licenses.gpl3;
    };
  };

  mssqlrelay = python3Packages.buildPythonPackage rec {
    pname = "mssqlrelay";
    version = "latest";
    src = super.fetchFromGitHub {
      owner = "CompassSecurity";
      repo = "mssqlrelay";
      rev = "bd764b9ba2be25374f26d277bebae54eb1be00b2";
      sha256 = "sha256-nNLtaD/CC3Fyk+VMOFmUyJdyP5jxBMcqChF3Zsm6vhI="; # Replace with the SHA-256 hash of the new source; nix-prefetch-url --unpack "https://github.com/CompassSecurity/mssqlrelay/archive/bd764b9ba2be25374f26d277bebae54eb1be00b2.tar.gz"
    };
    propagatedBuildInputs = with python3Packages; [ requests impacket ];
    meta = {
      description = "MS SQL relay utility for pentesting.";
      homepage = "https://github.com/CompassSecurity/mssqlrelay";
      license = super.lib.licenses.gpl2;
    };
  };

  adcheck = python3Packages.buildPythonPackage rec {
    pname = "adcheck";
    version = "1.5.0";

    src = super.fetchFromGitHub {
      owner = "CobblePot59";
      repo = "ADcheck";
      rev = "8fcb15e7cc5d5ade86fcf745eb204d13ca8ba8ef";
      sha256 = "sha256-lPNMzQLYLAsR3YvtGOnFnXiCBxbuZIkw0FmftAqE08c=";
    };

    format = "other";

    propagatedBuildInputs = with python3Packages; [ requests ldap3 ];

    installPhase = ''
      mkdir -p $out/bin
      cp adcheck/app.py $out/bin/

      # Add shebang line to make the script executable
      sed -i '1s;^;#!/usr/bin/env python3\n;' $out/bin/app.py

      # Create a symlink for `adcheck` pointing to `app.py`
      ln -sf $out/bin/app.py $out/bin/adcheck
      chmod +x $out/bin/adcheck
    '';

    meta = {
      description = "Active Directory checker tool.";
      homepage = "https://github.com/CobblePot59/ADcheck";
      license = super.lib.licenses.mit;
    };
  };

  adpeas = python3Packages.buildPythonPackage rec {
    pname = "adPEAS";
    version = "latest";
    src = super.fetchFromGitHub {
      owner = "ajm4n";
      repo = "adPEAS";
      rev = "bda3e0c01b61320e51d592e04fa01e82c0c2d440";
      sha256 = "sha256-GfEgYadvj0p3nTvOyELiNn5lYE+4sLoLojTSQcxUARo=";
    };
    propagatedBuildInputs = with python3Packages; [ ldap3 pandas ];
    meta = {
      description = "Active Directory post-exploitation enumeration tool.";
      homepage = "https://github.com/ajm4n/adPEAS";
      license = super.lib.licenses.asl20;
    };
  };

  mssqlpwner = super.poetry2nix.mkPoetryApplication {
    python = python3;
    projectDir = super.fetchFromGitHub {
      owner = "ScorpionesLabs";
      repo = "MSSqlPwner";
      rev = "a30f41f191d542695e9e19bcc711e2dd1af85abd";
      sha256 = "sha256-pMOsoGycs81htwcFN8JfbMMoSIMts4nyek62njpjTug=";
    };
  };

  bloodhound-python_ce = python3Packages.buildPythonPackage rec {
    pname = "bloodhound-python_ce";
    version = "latest";

    src = super.fetchFromGitHub {
      owner = "dirkjanm";
      repo = "BloodHound.py";
      rev = "093be56a3ff4a0529b5029a31a254f989acc3476"; # branch: bloodhound-ce
      sha256 = "sha256-wfwkqFl/gG75iwRgiEu+mjyKX9Q5qvbPjuOS6uP7Urk=";
    };

    propagatedBuildInputs = with python3Packages; [
      ldap3
      neo4j
      requests
      pycryptodome
    ];

    postInstall = ''
      mv $out/bin/bloodhound-python $out/bin/bloodhound-python_ce
      chmod +x $out/bin/bloodhound-python_ce
    '';

    meta = {
      description = "BloodHound Python for Active Directory enumeration and analysis (Community Edition)";
      homepage = "https://github.com/dirkjanm/BloodHound.py/tree/bloodhound-ce";
      license = super.lib.licenses.mit;
    };
  };

  python3 = super.python312.override {
    packageOverrides = python-self: python-super: {
      ldap3 = python-super.ldap3.overrideAttrs (oldAttrs: rec {
        propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ python-super.pycryptodome ];
      });

      # Optionally, override ldapdomaindump if needed
      ldapdomaindump = python-super.ldapdomaindump.overrideAttrs (oldAttrs: rec {
        propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ python-self.ldap3 ];
      });
    };
  };

  # Use `python3.pkgs` for Python packages
  python3Packages = python3.pkgs;

in
{
  # Use `python3` from `self` (overridden)
  inherit python3;

  linWinPwn = self.stdenv.mkDerivation rec {
    pname = "linWinPwn";
    version = "latest";

    src = super.fetchFromGitHub {
      owner = "lefayjey";
      repo = "linWinPwn";
      rev = "d6226338a77da7af802249aa1da89bb7e71a5492";
      sha256 = "sha256-OrnHhCyvSkA1dBqTcY7Ib1MWsgR/6xHDOsKPbjjZYsI=";
    };

    nativeBuildInputs = [
      self.makeWrapper
      self.unzip
      python3Packages.pip
      python3Packages.setuptools
      python3Packages.virtualenv
      self.git
    ];

    buildInputs = [
      (python3.withPackages (ps: with ps; [
        mssqlrelay
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
        ps.ldap3
      ]))
      adpeas
      adcheck
      mssqlpwner
      bloodhound-python_ce
      manspider
      self.nmap
      self.smbmap
      self.john
      self.swig
      self.openssl
      self.curl
      self.jq
      self.netexec
      self.adidnsdump
      self.certipy
      self.ldeep
      self.pre2k
      self.certsync
      self.coercer
      self.donpapi
      self.rdwatool
      self.krbjack
      self.breads-ad
      self.smbclient-ng
      self.hekatomb
      self.enum4linux-ng
      self.evil-winrm-patched
      self.util-linux
    ];

    installPhase = ''
      mkdir -p $out/bin $out/usr/bin $out/opt/linWinPwn/scripts

      # Perform substitutions on linWinPwn.sh
      substituteInPlace linWinPwn.sh \
          --replace-quiet "/bin/touch" "touch" \
          --replace-quiet "/usr/bin/script" "script"

      # Copy main linWinPwn script to $out/bin
      cp linWinPwn.sh $out/bin/linWinPwn
      chmod +x $out/bin/linWinPwn

      # Copy tools to the scripts directory
      ${self.lib.concatStringsSep "\n" (map (tool: ''
        cp ${tool} $out/bin/${tool.name}
        chmod +x $out/bin/${tool.name}
      '') fetchTools)}

      runHook postInstall
    '';

    postInstall = ''
      # Wrap the main linWinPwn script
      wrapProgram $out/bin/linWinPwn \
        --set PATH "${self.lib.makeBinPath ([
          self.coreutils
          self.which
          self.iproute2
          self.gnused
          python3
          self.gnugrep
          self.gawk
          self.util-linux
          self.sudo
          self.findutils
          mssqlrelay
          adcheck
          adpeas
          mssqlpwner
          bloodhound-python_ce
          manspider
          python3Packages.impacket
          python3Packages.ldapdomaindump
          python3Packages.pycryptodome
          python3Packages.pandas
          python3Packages.requests
          python3Packages.bloodhound-py
          python3Packages.bloodyad
          self.nmap
          self.smbmap
          self.john
          self.swig
          self.openssl
          self.curl
          self.jq
          self.netexec
          self.adidnsdump
          self.certipy
          self.ldeep
          self.pre2k
          self.certsync
          self.coercer
          self.donpapi
          self.rdwatool
          self.krbjack
          self.breads-ad
          self.smbclient-ng
          self.hekatomb
          self.enum4linux-ng
          self.certi
          self.evil-winrm-patched
        ] ++ fetchTools)}:$out/bin:$out/usr/bin"

      # Ensure all binaries in $out/bin are executable
      chmod +x $out/bin/*
    '';

    meta = {
      description = "Swiss-Army knife for Active Directory Pentesting using Linux";
      homepage = "https://github.com/lefayjey/linWinPwn";
      license = super.lib.licenses.gpl3Plus;
    };
  };

}
