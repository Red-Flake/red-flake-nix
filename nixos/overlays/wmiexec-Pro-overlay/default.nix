self: super:

{
  wmiexec-Pro = super.stdenv.mkDerivation rec {
    pname = "wmiexec-Pro";
    version = "unstable-2025-01-03"; # Use today's date as version

    src = super.fetchFromGitHub {
      owner = "XiaoliChan";
      repo = "wmiexec-Pro";
      rev = "6a12e5ec057cf0fa949da92b056d0f60af3d72c9"; # Replace with the specific commit hash if needed
      sha256 = "sha256-tcBv6JhfkAthVoQ4wE9xYU3TdejdJ53gjLywBP1RGc0="; # Replace with the actual hash
    };

    meta = with super.lib; {
      description = "New generation of wmiexec.py with AV evasion features";
      homepage = "https://github.com/XiaoliChan/wmiexec-Pro";
      license = licenses.gpl3; # Replace with the correct license if available
      maintainers = with maintainers; [ lib.maintainers.Mag1cByt3s ];
    };

    buildInputs = [
      (super.python312.withPackages (ps: with ps; [
        impacket
        numpy
      ]))
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp -r $src/* $out/bin/
      # Add shebang line to make the script executable
      sed -i '1s;^;#!/usr/bin/env python3\n;' $out/bin/wmiexec-pro.py
      ln -s $out/bin/wmiexec-pro.py $out/bin/wmiexec-pro
      ln -s $out/bin/wmiexec-pro.py $out/bin/wmiexec-Pro
      chmod +x $out/bin/wmiexec-pro.py
      chmod +x $out/bin/wmiexec-pro
      chmod +x $out/bin/wmiexec-Pro
    '';
  };
}
