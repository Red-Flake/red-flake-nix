_self: super: {
  wordlists = super.stdenv.mkDerivation {
    pname = "wordlists";
    version = "1.0";

    # Fetch the repository using fetchgit with Git LFS support.
    src = super.fetchgit {
      url = "https://github.com/Red-Flake/wordlists.git";
      rev = "74d0068ee15e97b749304886b20e306a24d84dcc"; # e.g. commit hash or branch name
      sha256 = "sha256-4gftUtrucXu1To+AjCfbQoBHZzIEdbXB6vjJZdaHahg=";
      fetchLFS = true;
    };

    phases = [
      "unpackPhase"
      "installPhase"
    ];

    installPhase = ''
      mkdir -p $out/share/wordlists
      cp -r * $out/share/wordlists
    '';
  };
}
