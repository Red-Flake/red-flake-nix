{ inputs
, pkgs
, pkgsUnstable
, ...
}:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bloodhound
    inputs.redflake-packages.packages.x86_64-linux.bloodhound-ce-py
    bloodhound-quickwin
    pkgsUnstable.python313Packages.impacket
    openldap
    ldapdomaindump-patched
    pkgsUnstable.certipy
    pkgsUnstable.netexec
    powershell
    pkgsUnstable.python313Packages.bloodyad
    krb5
    krb5.dev
    samba4Full
    pkgsUnstable.autobloody
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
    pkgsUnstable.pywhisker
  ];
}
