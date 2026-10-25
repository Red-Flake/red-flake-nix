# rea-overlay
# REA (Reverse Engineer Anything) - MCP server + CLI for reverse engineering.
# https://github.com/morluto/rea
#
# The npm tarball ships no lockfile, so package-lock.json is generated with:
#   npm pack rea-agents@<version> && tar xzf rea-agents-<version>.tgz
#   cd package
#   jq 'del(.optionalDependencies)' package.json > p.json && mv p.json package.json
#   npm install --package-lock-only --ignore-scripts
#
# frida (optional, dynamic instrumentation) is dropped: its install script
# downloads prebuilt binaries, which the Nix sandbox blocks.
#
# Needs Node ^22.23.4 || ^24.22.1 || >=26.12.1. Install it from pkgsUnstable
# (stable's nodejs_26 is too old).
final: _prev:

{
  rea-agents = final.buildNpmPackage rec {
    pname = "rea-agents";
    version = "6.8.0";

    src = final.fetchurl {
      url = "https://registry.npmjs.org/rea-agents/-/rea-agents-${version}.tgz";
      hash = "sha256-jVQux2qcs1BYS2CmycCIcG/4EtW7WwlMIMlbbcJWmLs=";
    };

    nodejs = final.nodejs_26;

    # Drop the optionalDependencies block (frida only); also runs in the
    # npm-deps fetcher, so stick to coreutils/sed.
    postPatch = ''
      sed -i '/"optionalDependencies": {/,/},/d' package.json
      cp ${./package-lock.json} package-lock.json
    '';

    npmDepsHash = "sha256-WCxgux8D0+G2siPua3k1xSUMiV/Yry4s/evhpX2EEe4=";

    # Published tarball is already built.
    dontNpmBuild = true;

    meta = with final.lib; {
      description = "One MCP for reverse engineering across binaries, applications, and runtime behavior";
      homepage = "https://github.com/morluto/rea";
      license = licenses.mit;
      mainProgram = "rea";
      platforms = platforms.linux;
    };
  };
}
