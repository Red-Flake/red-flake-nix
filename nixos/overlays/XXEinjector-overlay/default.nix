# XXEinjector-overlay.nix
self: super: {

  xxeinjector = super.stdenv.mkDerivation rec {
    pname = "XXEinjector";
    version = "unstable-2020-08-27";  # Based on the last commit date; the repo hasn't been updated since

    src = super.fetchFromGitHub {
      owner = "enjoiz";
      repo = "XXEinjector";
      rev = "68d2e8e6cbad0ab1b2774646dcdaf469ad7fe213";
      hash = "sha256-TkDcJxjnNfO90rPUxferuijsoM34dtKi/y1YcfNufrY=";
    };

    buildInputs = [ super.ruby ];

    postPatch = ''
      substituteInPlace XXEinjector.rb \
        --replace 'ruby #{__FILE__}' 'XXEinjector'
    '';

    installPhase = ''
      runHook preInstall
      install -Dm755 XXEinjector.rb $out/bin/XXEinjector
      patchShebangs $out/bin/XXEinjector
      runHook postInstall
      runHook postPatch
    '';

    meta = with super.lib; {
      description = "Tool for automatic exploitation of XXE vulnerability using direct and different out of band methods";
      homepage = "https://github.com/enjoiz/XXEinjector";
      license = licenses.mit;
      maintainers = with maintainers; [ maintainers.Mag1cByt3s ];
      platforms = platforms.all;
    };
  };

}