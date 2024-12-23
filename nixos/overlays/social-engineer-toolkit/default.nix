# social-engineer-toolkit-overlay.nix
final: prev: 

{
  social-engineer-toolkit = final.python3Packages.buildPythonApplication rec {
    pname = "social-engineer-toolkit";
    version = "8.0.3";
    format = "other";

    src = final.fetchFromGitHub {
      owner = "trustedsec";
      repo = pname;
      rev = version;
      sha256 = "ePbmUvnzLO0Wfuhym3bNSPV1x8rcCPqKMeWSRcbJGAo=";
    };

    postPatch = ''
      substituteInPlace setoolkit \
        --replace "src/core/config.baseline" "$out/share/social-engineer-toolkit/src/core/config.baseline" \
        --replace "src/logs/" "/var/lib/social-engineer-toolkit/logs" \
        --replace "src/program_junk" "/var/lib/social-engineer-toolkit/program_junk" \
        --replace "src/agreement4" "/var/lib/social-engineer-toolkit/agreement4"

      substituteInPlace src/core/setcore.py \
        --replace '"src/core/set.version"' "\"$out/share/social-engineer-toolkit/src/core/set.version\"" \
        --replace "src/logs/set_logfile.log" "/var/lib/social-engineer-toolkit/logs/set_logfile.log" \
        --replace "src/logs/" "/var/lib/social-engineer-toolkit/logs" \
        --replace "src/program_junk" "/var/lib/social-engineer-toolkit/program_junk" \
        --replace "/opt/metasploit-framework" "${final.metasploit}/bin"

      substituteInPlace src/webattack/harvester/harvester.py \
        --replace "src/logs/harvester.log" "/var/lib/social-engineer-toolkit/logs/harvester.log" \
        --replace "src/logs/" "/var/lib/social-engineer-toolkit/logs"

      substituteInPlace src/payloads/set_payloads/listener.py \
        --replace "src/logs/set_logfile.log" "/var/lib/social-engineer-toolkit/logs/set_logfile.log" \
        --replace "src/logs/" "/var/lib/social-engineer-toolkit/logs"
    '';

    nativeBuildInputs = [
      final.makeWrapper
    ];

    propagatedBuildInputs = with final.python3Packages; [
      pexpect
      pycrypto
      requests
      pyopenssl
      pefile
      impacket
      qrcode
      pillow
      # Has been abandoned upstream. Features using this library are broken
      # pymssql
    ];

    installPhase = ''
      runHook preInstall

      install -Dt $out/bin setoolkit seautomate seproxy
      mkdir -p $out/share/social-engineer-toolkit
      cp -r modules readme src $out/share/social-engineer-toolkit/

      runHook postInstall
    '';

    makeWrapperArgs = [
      "--chdir ${placeholder "out"}/share/social-engineer-toolkit"
      "--prefix PYTHONPATH : \"${placeholder "out"}/share/social-engineer-toolkit\""
      "--run \"mkdir -p /var/lib/social-engineer-toolkit /var/lib/social-engineer-toolkit/logs\""
    ];

    # Project has no tests
    doCheck = false;

    meta = with final.lib; {
      description = "Open-source penetration testing framework designed for social engineering";
      longDescription = ''
        The Social-Engineer Toolkit is an open-source penetration testing framework
        designed for social engineering. SET has a number of custom attack vectors
        that allow you to make a believable attack quickly.
      '';
      homepage = "https://github.com/trustedsec/social-engineer-toolkit";
      mainProgram = "setoolkit";
      license = licenses.bsd3;
      maintainers = with final.maintainers; [ emilytrau ];
    };
  };
}
