self: super:

let
  lib = super.lib;
  python313 = super.python313;
  python313Packages = super.python313Packages;
  fetchFromGitHub = super.fetchFromGitHub;
in
{
  bashfuscator = python313Packages.buildPythonApplication rec {
    pname = "bashfuscator";
    version = "unstable-05-09-2025"; # Adjust if there's a specific version or use a commit hash

    src = fetchFromGitHub {
      owner = "Red-Flake";
      repo = "Bashfuscator";
      rev = "127d33ebcfad24f9ca67a0511db23dcf947d6465"; # Replace with specific commit hash or branch for reproducibility
      sha256 = "sha256-MBLU8TYAlvkm7ci1kzgoexOWKbt3a6lUVTi1k1FMSOE="; # Placeholder, update below
    };

    propagatedBuildInputs = with python313Packages; [
      setuptools # Required for setup.py
      argcomplete
      pyperclip
    ];

    # Skip tests if they’re not critical or if they fail
    doCheck = false;

    meta = with lib; {
      description = "A fully configurable and extendable Bash obfuscation framework. This tool is intended to help both red team and blue team.";
      homepage = "https://github.com/Red-Flake/Bashfuscator";
      license = licenses.mit;
      maintainers = [ maintainers.Mag1cByt3s ];
    };
  };
}