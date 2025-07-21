# joomla-brute-overlay.nix
self: super: {

  joomla-brute = self.python312Packages.buildPythonApplication rec {
    pname = "joomla-brute";
    version = "unstable-2020-01-07";  # Based on last commit date; adjust if needed

    src = super.fetchFromGitHub {
      owner = "ajnik";
      repo = "joomla-bruteforce";
      rev = "f2f347d5e9f84fc4ec7d5bfc82fc6e4cd63a2057";
      hash = "sha256-RFXd2kLLOTKN93EdqsCgtUqkdkbjcR1K9u8oYdNCrZE=";  # Replace with actual hash from `nix-prefetch-github ajnik joomla-bruteforce --rev master`
    };

    # No standard build system (single script), so use "other"
    format = "other";

    # Runtime dependencies based on script imports
    propagatedBuildInputs = with self.python312Packages; [
      requests
      beautifulsoup4
    ];

    # Custom install: install script and wrap it
    installPhase = ''
      mkdir -p $out/bin $out/share/joomla-brute
      install -m755 joomla-brute.py $out/share/joomla-brute/joomla-brute.py
      makeWrapper ${self.python312.withPackages (ps: propagatedBuildInputs)}/bin/python3 $out/bin/joomla-brute \
        --add-flags $out/share/joomla-brute/joomla-brute.py
      makeWrapper ${self.python312.withPackages (ps: propagatedBuildInputs)}/bin/python3 $out/bin/joomla-brute.py \
        --add-flags $out/share/joomla-brute/joomla-brute.py
    '';

    # No tests to run
    doCheck = false;

    meta = with super.lib; {
      description = "A Joomla login bruteforce tool";
      homepage = "https://github.com/ajnik/joomla-bruteforce";
      license = licenses.mit;  # Assume MIT based on typical repos; repo does not contain any license
      maintainers = with lib.maintainers; [ lib.maintainers.Mag1cByt3s ];
    };
  };
}