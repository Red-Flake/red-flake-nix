self: super: {
  wordlists = super.stdenv.mkDerivation {
    pname = "wordlists";
    version = "1.0";

    # Fetch the repository using fetchgit with Git LFS support.
    src = super.fetchgit {
      url = "https://github.com/Red-Flake/wordlists.git";
      rev = "c898f2e1dd3c7b7eca29d343e1acd4cdf611d152"; # e.g. commit hash or branch name
      sha256 = "sha256-KItRcgVu7InEy3nrviBXZjDTTY8ZBT4nkOuNiJFptCk=";
      fetchLFS = true;
    };

    # We only need the install phase since the repo is already unpacked.
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      mkdir -p $out/share/wordlists
      cp -r * $out/share/wordlists
    '';
  };
}
