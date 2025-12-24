# powerview-py-overlay.nix
_self: super: {
  powerview-py = super.python312Packages.buildPythonPackage rec {
    pname = "powerview-py";
    version = "2025.0.4";

    src = super.fetchFromGitHub {
      owner = "aniqfakhrul";
      repo = "powerview.py";
      rev = "cfb51cbbfe7adc1ccc4fceb2c81cc8ff73829c0b";
      sha256 = "sha256-AYe4MJaaHPm9ID8Ax79+VfXUsvgf7Ox34d8YYCWr0vQ=";
    };

    format = "pyproject";

    nativeBuildInputs = with super.python312Packages; [
      poetry-core
      setuptools
    ];

    propagatedBuildInputs = with super.python312Packages; [
      impacket
      ldap3-bleeding-edge
      dnspython
      future
      gnureadline
      validators
      dsinternals
      chardet
      tabulate
      requests-ntlm
      python-dateutil
      flask
    ];

    postPatch = ''
      # Remove argparse from setup.py and pyproject.toml
      sed -i '/argparse/d' setup.py
      sed -i '/argparse/d' pyproject.toml
      sed -i '/argparse/d' requirements.txt
    '';

    # 🚨 OVERRIDE THE BROKEN CHECK 🚨
    pythonRemoveDeps = [ "argparse" ];

    doCheck = false; # Skipping tests if none exist or fail due to missing dependencies

    meta = with super.lib; {
      description = "Python implementation of PowerView from PowerSploit";
      homepage = "https://github.com/aniqfakhrul/powerview.py";
      license = licenses.mit;
      maintainers = with maintainers; [ ];
    };
  };
}
