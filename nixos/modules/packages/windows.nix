{
  inputs,
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bloodhound
    inputs.redflake-packages.packages.x86_64-linux.bloodhound-ce-py
    bloodhound-quickwin
    python312Packages.impacket-patched
    openldap
    ldapdomaindump-patched
    python312Packages.certipy-ad
    netexec
    powershell
    python313Packages.bloodyad
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
    adenum
    wimlib
    shortscan
  ];
}
