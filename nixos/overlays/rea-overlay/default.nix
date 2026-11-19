# rea-overlay
# REA (Reverse Engineer Anything) - MCP server + CLI for reverse engineering.
# https://github.com/morluto/rea
#
# The package itself comes from github:Fractal-Tess/rea-flake (input `rea-flake`),
# which tracks npm releases and carries the lockfile. This overlay only points it
# at ghidra-bin and wraps it with the optional analysis tools (see ./package.nix).
#
# Use it from pkgsUnstable: rea-flake follows nixpkgs-unstable, and several pinned
# tools (unblob 26.6.x, ghidra-bin 12.2, openjdk25) only exist there.
{ inputs }:
final: _prev:

{
  rea-agents = final.callPackage ./package.nix {
    rea = inputs.rea-flake.packages.${final.stdenv.hostPlatform.system}.rea.override {
      # Same Ghidra the system already installs, instead of a second source build.
      ghidra = final.ghidra-bin;
      # Ghidra 12.2 requires JDK 25+ (application.java.min=25), while rea-flake
      # still wires JAVA_HOME to openjdk21.
      openjdk21 = final.openjdk25;
    };
  };
}
