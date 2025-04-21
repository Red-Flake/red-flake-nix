self: super: {
  wordlists = super.stdenv.mkDerivation {
    pname = "wordlists";
    version = "1.0";

    # Fetch the repository using fetchgit with Git LFS support.
    src = super.fetchgit {
      url = "https://github.com/Red-Flake/wordlists.git";
      rev = "9c1c4a80cb999be0f72c0d5e592cdf1a29a52e24"; # e.g. commit hash or branch name
      sha256 = "sha256-5o3Y6tcK7lTGMaQ/kEeTlKazZIlb2YMaBfPAIsouV+E=";
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
