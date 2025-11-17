self: super: {
  wordlists = super.stdenv.mkDerivation {
    pname = "wordlists";
    version = "1.0";

    # Fetch the repository using fetchgit with Git LFS support.
    src = super.fetchgit {
      url = "https://github.com/Red-Flake/wordlists.git";
      rev = "4527384f1d0e919fa89d8d613be23c31122ee2aa"; # e.g. commit hash or branch name
      sha256 = "sha256-UkqkfbJrWBjjly4Pbm4rXA1oGJc5kUGUZHgoH3iyL14=";
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
