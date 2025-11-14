self: super: {
  wordlists = super.stdenv.mkDerivation {
    pname = "wordlists";
    version = "1.0";

    # Fetch the repository using fetchgit with Git LFS support.
    src = super.fetchgit {
      url = "https://github.com/Red-Flake/wordlists.git";
      rev = "2a5f870fb6bb7880571bcbf66165295f8c31dba7"; # e.g. commit hash or branch name
      sha256 = "sha256-WisOCYFR8zUkKjU3XTj4LHqszqJ0P2Vpk6FIADT4rpo=";
      fetchLFS = true;
    };

    # We only need the install phase since the repo is already unpacked.
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
