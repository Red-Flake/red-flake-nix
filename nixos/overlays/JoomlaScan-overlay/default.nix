# JoomlaScan-overlay.nix
self: super: {

  JoomlaScan = self.python312Packages.buildPythonApplication rec {
    pname = "JoomlaScan";
    version = "unstable-2022-09-23"; # Adjust to a tag or date if preferred

    src = super.fetchFromGitHub {
      owner = "drego85";
      repo = "JoomlaScan";
      rev = "9f7650fa3007cd1d6631ab53edb647b4b5ef5724";
      hash = "sha256-hOuXTywixFybF2KrdiAiuD82pyJTEEM7KdqsMcR4vVs="; # Replace with actual hash from `nix-prefetch-github drego85 JoomlaScan --rev 9f7650fa3007cd1d6631ab53edb647b4b5ef5724`
    };

    # No standard build system (single script), so use "other"
    format = "other";

    # Runtime dependencies based on script imports
    propagatedBuildInputs = with self.python312Packages; [
      requests
      beautifulsoup4
      termcolor
    ];

    # Use 2to3 to convert Python 2 syntax to Python 3 (including print statements)
    postPatch = ''
      ${self.python312}/bin/2to3 -w joomlascan.py
      sed -i '/import time/a import os' joomlascan.py
      substituteInPlace joomlascan.py \
        --replace 'open("comptotestdb.txt"' 'open(os.path.join(os.path.dirname(__file__), "comptotestdb.txt")' \
        --replace 'url[-1:] is "/"' 'url[-1:] == "/"'
    '';

    # Custom install: install script and data file, wrap the script
    installPhase = ''
      mkdir -p $out/bin $out/share/joomlascan
      install -m755 joomlascan.py $out/share/joomlascan/joomlascan.py
      install -m644 comptotestdb.txt $out/share/joomlascan/comptotestdb.txt
      makeWrapper ${self.python312.withPackages (ps: propagatedBuildInputs)}/bin/python $out/bin/joomlascan \
        --add-flags $out/share/joomlascan/joomlascan.py
    '';

    # No tests to run
    doCheck = false;

    meta = with super.lib; {
      description = "A free software to find the components installed on a Joomla CMS and to find components with known vulnerabilities";
      homepage = "https://github.com/drego85/JoomlaScan";
      license = licenses.gpl3;
      maintainers = with lib.maintainers; [ lib.maintainers.Mag1cByt3s ];
    };
  };
}
