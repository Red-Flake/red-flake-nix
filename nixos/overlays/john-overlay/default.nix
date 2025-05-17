# john-overlay.nix
self: super:

let
  lib = super.lib;
  fetchFromGitHub = super.fetchFromGitHub;
in {
  john = super.john.overrideAttrs (old: {
    version = "unstable-2025-05-01";

    src = fetchFromGitHub {
      owner = "openwall";
      repo = "john";
      rev = "8b5bfefbdc9b643513037f30c8200f5dc0ffc841"; # https://github.com/openwall/john/commit/8b5bfefbdc9b643513037f30c8200f5dc0ffc841
      hash = "sha256-R1HzCeutxOWRlTZzEun9OtP1n/LCa6rKVzBs1meTNf0="; # ← update this
    };

    # Remove the opencl.patch
    patches = [];

    # Optional: override patches or additional preConfigure logic
    #preConfigure = old.preConfigure + lib.optionalString old.withOpenCL ''
    #  python3 ./opencl_generate_dynamic_loader.py
    #'';
  });
}
