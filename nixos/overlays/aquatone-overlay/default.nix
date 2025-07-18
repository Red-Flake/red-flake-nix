# aquatone-overlay.nix
self: super: {

  aquatone = super.buildGoModule rec {
    pname = "aquatone";
    version = "1.9.1-shelld3v";

    src = super.fetchFromGitHub {
      owner = "shelld3v";
      repo = "aquatone";
      rev = "v${version}";
      hash = "sha256-TI+bKTzkDiToUqdbTI2nWXTVPRNayYihC2iNFxqtk8I=";
    };

    vendorHash = "sha256-vNJu8PXxENzr0XorLMkj0D75477yMU2mD6NPNM3pJZg=";

    nativeBuildInputs = [ super.makeWrapper ];

    buildInputs = [ super.chromium ];  # Runtime dependency for headless screenshots

    postPatch = ''
      sed -i '/import (/a\ \ "os/user"' core/session.go
      sed -i '/session.Options.OutDir = envOutPath/a \ \ session.Options.OutDir = os.ExpandEnv(session.Options.OutDir)\n\ \ if strings.HasPrefix(session.Options.OutDir, "~\/") {\n\ \ \ \ u, err := user.Current()\n\ \ \ \ if err == nil {\n\ \ \ \ \ \ session.Options.OutDir = u.HomeDir + session.Options.OutDir[1:]\n\ \ \ \ }\n\ \ }' core/session.go
      sed -i 's/os\.Mkdir/os.MkdirAll/g' core/session.go
    '';

    postInstall = ''
      wrapProgram $out/bin/aquatone \
        --set AQUATONE_CHROME_PATH "${super.chromium}/bin/chromium" \
        --set AQUATONE_OUT_PATH "~/aquatone"
    '';

    meta = with super.lib; {
      description = "A tool for visual inspection of websites across a large number of hosts, providing a quick overview of HTTP-based attack surfaces";
      homepage = "https://github.com/shelld3v/aquatone";
      license = licenses.mit;
      maintainers = [ maintainers.Mag1cByt3s ];
      platforms = platforms.all;
    };
  };

}