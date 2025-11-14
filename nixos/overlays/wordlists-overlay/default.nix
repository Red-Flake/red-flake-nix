self: super: {
  wordlists = super.stdenv.mkDerivation {
    pname = "wordlists";
    version = "1.0";

    # Fetch the repository using fetchgit with Git LFS support.
    src = super.fetchgit {
      url = "https://github.com/Red-Flake/wordlists.git";
      rev = "fe19f0e9cf0810dae4fa4247b0d3401b71d586c2"; # e.g. commit hash or branch name
      sha256 = "sha256-YicfvyAJ2mUAbsrkzBxtNrk6JL5RUtm3I50SA3iWbT4=";
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
