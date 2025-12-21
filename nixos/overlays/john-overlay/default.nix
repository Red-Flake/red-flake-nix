# john-overlay.nix
_self: super:

let
  fetchFromGitHub = super.fetchFromGitHub;
in
{
  john = super.john.overrideAttrs (old: {
    version = "unstable-2025-06-15";

    src = fetchFromGitHub {
      owner = "openwall";
      repo = "john";
      rev = "2c69bc24d0a2f5539b2ca95393f0231912f1756b"; # https://github.com/openwall/john/commit/2c69bc24d0a2f5539b2ca95393f0231912f1756b
      hash = "sha256-EaVaHa35213vUbmZk/RNnAF2MjDG1BCyvqA14JSzGnE="; # ← update this
    };

    propagatedBuildInputs = old.propagatedBuildInputs ++ [
      super.python3Packages.pyhanko
    ];

    # Remove the opencl.patch
    patches = [ ];

    # Optional: override patches or additional preConfigure logic
    #preConfigure = old.preConfigure + lib.optionalString old.withOpenCL ''
    #  python3 ./opencl_generate_dynamic_loader.py
    #'';
  });
}
