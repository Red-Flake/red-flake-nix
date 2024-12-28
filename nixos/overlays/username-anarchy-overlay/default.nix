# username-anarchy-overlay.nix
self: super:

let
  lib = super.lib;
in
{
  username-anarchy = super.username-anarchy.overrideAttrs (oldAttrs: rec {
    version = "0.6";

    src = super.fetchFromGitHub {
      rev = "v0.6"; # v0.6
      owner = "urbanadventurer";
      repo = "username-anarchy";
      hash = "sha256-46hl1ynA/nc2R70VHhOqbux6B2hwiJWs/sf0ZRwNFf0="; # Replace with the actual hash after fetching
    };

    # Optional: Add ruby dependencies if needed
    buildInputs = oldAttrs.buildInputs;

    preInstall = ''
      mkdir -p $out/bin
      install -Dm 555 format-plugins.rb $out/bin/
      install -Dm 555 username-anarchy $out/bin/
    '';

    meta = oldAttrs.meta // {
      homepage = "https://github.com/urbanadventurer/username-anarchy/";
      description = "Username generator tool for penetration testing (updated version 0.6)";
    };
  });
}
