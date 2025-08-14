self: super: {
  wordlists = super.stdenv.mkDerivation {
    pname = "wordlists";
    version = "1.0";

    # Fetch the repository using fetchgit with Git LFS support.
    src = super.fetchgit {
      url = "https://github.com/Red-Flake/wordlists.git";
      rev = "a64e96a5685ff5e364ce067dd27dc551a4e9234c"; # e.g. commit hash or branch name
      sha256 = "sha256-XU3eL5O8NyUYWnplQc65E6b1gQhR/Z80tZMBr9DIMOk=";
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
