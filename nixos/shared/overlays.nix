# Shared overlay configuration for all Red-Flake hosts
{ inputs, ... }:
{
  # All overlays that should be available to all hosts
  # (except intel-legacy which is conditional)
  allOverlays = [
    # Lix overlay
    (_: prev: {
      inherit (prev.lixPackageSets.stable)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })

    # Chaotic-Nyx overlay
    (_: prev: {
      chaoticPkgs = import inputs.chaotic { inherit (prev) system; };
    })

    # NUR overlay
    inputs.nur.overlays.default

    # poetry2nix overlay
    inputs.poetry2nix.overlays.default

    # https://github.com/xddxdd/nix-cachyos-kernel
    # use the exact kernel versions as defined in this repo.
    # Guarantees you have binary cache.
    inputs.nix-cachyos-kernel.overlays.pinned

    # redflake-packages overlay
    inputs.redflake-packages.overlays.default

    # fix issues with samba4Full
    (_: prev: {
      samba4Full = prev.samba4Full.override { enableCephFS = false; }; # disable cephfs in order to get around issues with => fatal error: tommath.h: No such file or directory
    })

    # Security tool overlays
    (import ../overlays/impacket-overlay)
    (import ../overlays/responder-overlay)
    (import ../overlays/evil-winrm-overlay)
    (import ../overlays/bloodhound-quickwin-overlay)
    (import ../overlays/ldapdomaindump-overlay)
    (import ../overlays/SMB_Killer-overlay)
    (import ../overlays/pyGPOAbuse-overlay)
    (import ../overlays/spose-overlay)
    (import ../overlays/netexec-overlay inputs)
    (import ../overlays/nmapAutomator-overlay)
    (import ../overlays/autobloody-overlay)
    (import ../overlays/social-engineer-toolkit)
    (import ../overlays/username-anarchy-overlay)
    (import ../overlays/wmiexec-Pro-overlay)
    (import ../overlays/ntlm_theft-overlay)
    (import ../overlays/kerbrute-overlay)
    (import ../overlays/DNSenum-overlay)
    (import ../overlays/smtp-user-enum-overlay)
    (import ../overlays/powerview-py-overlay)
    (import ../overlays/dnscat2-overlay)
    (import ../overlays/wordlists-overlay)
    (import ../overlays/PKINITtools-overlay)
    (import ../overlays/PetitPotam-overlay)
    (import ../overlays/cupp-overlay)
    (import ../overlays/john-overlay)
    #(import ../overlays/certipy-overlay)
    (import ../overlays/XSStrike-overlay)
    (import ../overlays/XSSer-overlay)
    (import ../overlays/bashfuscator-overlay)
    (import ../overlays/sliver-overlay)
    (import ../overlays/XXEinjector-overlay)
    (import ../overlays/aquatone-overlay)
    (import ../overlays/eyewitness-overlay)
    (import ../overlays/droopescan-overlay)
    (import ../overlays/JoomlaScan-overlay)
    (import ../overlays/joomla-brute-overlay)
    (import ../overlays/apachetomcatscanner-overlay)
    (import ../overlays/freerdp-overlay)
    (import ../overlays/mingwW64-overlay)
    (import ../overlays/metasploit-overlay)
  ];

  # Intel legacy overlay (conditional)
  intelLegacyOverlay = [
    (import ../overlays/intel-legacy-overlay)
  ];

  # TUXEDO drivers overlay (conditional - only for TUXEDO laptops)
  tuxedoDriversOverlay = [
    (import ../overlays/tuxedo-drivers-overlay)
  ];
}
