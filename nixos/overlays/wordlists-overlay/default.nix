self: super: {
  wordlists = super.stdenv.mkDerivation {
    pname = "wordlists";
    version = "1.0";

    # Fetch the repository using fetchgit with Git LFS support.
    src = super.fetchgit {
      url = "https://github.com/Red-Flake/wordlists.git";
      rev = "3f20a0b27f0574d1937a324826659d7bd4d705bf"; # e.g. commit hash or branch name
      sha256 = "sha256-fTuj7FAOGWnfKTekIex3ZCf3VBx4OSqVpAV3Vrgt+Ek=";
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
