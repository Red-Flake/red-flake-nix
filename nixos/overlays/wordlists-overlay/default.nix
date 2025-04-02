self: super: {
  wordlists = super.stdenv.mkDerivation {
    pname = "wordlists";
    version = "1.0";

    # Fetch the repository using fetchgit with Git LFS support.
    src = super.fetchgit {
      url = "https://github.com/Red-Flake/wordlists.git";
      rev = "2c314dee7891da8b29f313ddc1c72023b3527b89"; # e.g. commit hash or branch name
      sha256 = "sha256-hzoIYxb/qJqc3piOhXdlUT9e+U5zU1OD0zZ9W91HFDQ=";
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
