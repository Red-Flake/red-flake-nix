# This overlay updates the tuxedo-drivers package to version 4.15.4
(final: prev: {
  tuxedo-drivers = prev.tuxedo-drivers.overrideAttrs (old: rec {
    version = "4.15.4";
    src = prev.fetchFromGitLab {
      group = "tuxedocomputers";
      owner = "development/packages";
      repo = "tuxedo-drivers";
      rev = "v${version}";
      sha256 = "sha256-WJeju+czbCw03ALW7yzGAFENCEAvDdKqHvedchd7NVY=";
    };
    # Upstream Makefile tries `cp -r etc usr /` in the install target.
    # Nix sandbox forbids writing to /, so just skip that part.
    postPatch = (old.postPatch or "") + ''
      substituteInPlace Makefile \
        --replace "cp -r etc usr /" "true"
    '';
  });
})
