self: super: {
  wordlists = super.stdenv.mkDerivation {
    pname = "wordlists";
    version = "1.0";

    # Fetch the repository using fetchgit with Git LFS support.
    src = super.fetchgit {
      url = "https://github.com/Red-Flake/wordlists.git";
      rev = "9fc64971cdc43ff2027711b67f3cb6cfb1ddaec2"; # e.g. commit hash or branch name
      sha256 = "sha256-hEHvLn/6YqANGvGzXBuSJKddgVEPTVYokKKOxNIjmF4=";
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
