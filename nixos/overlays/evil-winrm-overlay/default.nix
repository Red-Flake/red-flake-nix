# evil-winrm-overlay.nix
# FIX for evil-winrm: https://github.com/NixOS/nixpkgs/issues/255276#issuecomment-2208251089
# Pull request that fixes this issue: https://github.com/NixOS/nixpkgs/pull/324530

# evil-winrm-overlay.nix
final: prev:

let
  newVersion = "3.7";
  rev = "c22b7c287f94cdac5777661e06cf5910e2e7aadd"; # your commit
  src37 = final.fetchFromGitHub {
    owner = "Hackplayers";
    repo = "evil-winrm";
    inherit rev;
    hash = "sha256-fL4QAB4utf+Ar2LfswD4MKgfmzVLwWwwahfPI3o0Bk4=";
  };
in
{
  evil-winrm-patched = prev.evil-winrm.overrideAttrs (oldAttrs: rec {
    # bump version & source
    version = newVersion;
    src = src37;

    # keep the existing wrapper & makeWrapper
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ prev.makeWrapper ];

    # bring in MIT Kerberos so we get libgssapi_krb5.so.2
    buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ prev.krb5.lib ];

    # OpenSSL‑legacy hack
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

    # wrap the binary so that both OPENSSL_CONF and LD_LIBRARY_PATH are set
    postFixup = ''
      ${oldAttrs.postFixup or ""}
      wrapProgram $out/bin/evil-winrm \
        --prefix OPENSSL_CONF : ${openssl_conf} \
        --prefix LD_LIBRARY_PATH : ${prev.krb5.lib}/lib
    '';
  });
}
