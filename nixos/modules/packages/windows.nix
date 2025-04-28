{ inputs, config, lib, pkgs, modulesPath, ... }:

# issue:
#  Checking runtime dependencies for bloodyad-2.1.9-py3-none-any.whl
# >   - cryptography==44.0.1 not satisfied by version 44.0.2
# use old version python3.12-bloodyad
# see: https://lazamar.co.uk/nix-versions/?package=python3.12-bloodyad&version=2.1.7&fullName=python3.12-bloodyad-2.1.7&keyName=python312Packages.bloodyad&revision=028048884dc9517e548703beb24a11408cc51402&channel=nixos-unstable#instructions
#let
#    pkgs = import (builtins.fetchTarball {
#        url = "https://github.com/NixOS/nixpkgs/archive/028048884dc9517e548703beb24a11408cc51402.tar.gz";
#        sha256 = "0gamch7a5586q568s8i5iszxljm1lw791k507crzcwqrcm41rs8y";
#    }) {};
#
#    python312bloodyad = pkgs.python312Packages.bloodyad;
#in
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bloodhound
    bloodhound-py
    bloodhound-quickwin
    python312Packages.impacket-patched
    openldap
    ldapdomaindump-patched
    certipy
    netexec
    powershell
    #python312bloodyad
    krb5Full
    krb5Full.dev
    samba4Full
    autobloody
    python312Packages.lsassy
    ldeep
    #linWinPwn
    python312Packages.xlsxwriter
    pyGPOAbuse
    python312Packages.pypykatz
    wmiexec-Pro
    coercer
    ntlm_theft
    powerview-py
    pkinittools
    petitpotam
    adidnsdump
  ];
}
