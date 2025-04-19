# evil-winrm-overlay.nix
# FIX for evil-winrm: https://github.com/NixOS/nixpkgs/issues/255276#issuecomment-2208251089
# Pull request that fixes this issue: https://github.com/NixOS/nixpkgs/pull/324530

# evil-winrm-overlay.nix
# update to v3.7, commit ffe958c841da655ba3c44740ca22aa0eee9fc5ed
final: prev:

let
  newVersion = "3.7";
  rev     = "ffe958c841da655ba3c44740ca22aa0eee9fc5ed";
  src37 = final.fetchFromGitHub {
      owner = "Hackplayers";
      repo = "evil-winrm";
      rev = "${rev}"; # Replace with the updated revision if needed
      hash = "sha256-jr8glS732UvSt+qFkhhLFZUB7OIRpRj3SzXm6mVikrE="; # Replace with the SHA-256 hash of the new source; nix-prefetch-url --unpack "https://github.com/Pennyw0rth/NetExec/archive/6d4fdfdb2d0088405ea3139f4145f198671a0fda.tar.gz"
  };
in
{
  evil-winrm-patched = prev.evil-winrm.overrideAttrs (oldAttrs: rec {
    # bump version & source
    version = newVersion;
    src     = src37;

    # carry forward makeWrapper and OpenSSL‐legacy fix
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ prev.makeWrapper ];

    openssl_conf = prev.writeText "openssl.conf" ''
      openssl_conf = openssl_init

      [openssl_init]
      providers = provider_sect

      [provider_sect]
      default = default_sect
      legacy  = legacy_sect

      [default_sect]
      activate = 1

      [legacy_sect]
      activate = 1
    '';

    postFixup = ''
      ${oldAttrs.postFixup or ""}
      wrapProgram $out/bin/evil-winrm \
        --prefix OPENSSL_CONF : ${openssl_conf}
    '';
  });
}
