# Shared overlay configuration for all Red-Flake hosts
{ inputs, ... }:
let
  # Base overlays available to all hosts
  baseOverlays = [
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

    # redflake-packages overlay
    inputs.redflake-packages.overlays.default

    # fix issues with samba4Full
    (_: prev: {
      samba4Full = prev.samba4Full.override { enableCephFS = false; }; # disable cephfs in order to get around issues with => fatal error: tommath.h: No such file or directory
    })
  ];

  # Security tool overlays
  securityOverlays = [
    (import ../overlays/responder-overlay)
    (import ../overlays/bloodhound-quickwin-overlay)
    (import ../overlays/ldapdomaindump-overlay)
    (import ../overlays/SMB_Killer-overlay)
    (import ../overlays/pyGPOAbuse-overlay)
    (import ../overlays/spose-overlay)
    (import ../overlays/impacket-overlay)
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

  # Desktop specific overlays
  desktopOverlays = [
    # Fix Electron color issues on Wayland with wide-gamut displays
    (import ../overlays/electron-color-fix-overlay)

    # Equibop: writable settings.json + opt-in speech-dispatcher
    (import ../overlays/equibop-overlay)

    # Ghostty tip package
    (final: _prev: {
      ghostty = inputs.ghostty.packages.${final.system}.default;
    })

    # Ghostty: suppress noisy warnings in journald
    (import ../overlays/ghostty-overlay)
  ];
in
{
  inherit baseOverlays securityOverlays desktopOverlays;

  # Combined list for backward compatibility or full hosts
  allOverlays = baseOverlays ++ securityOverlays ++ desktopOverlays;

  # Intel legacy overlay (conditional)
  intelLegacyOverlay = [
    (import ../overlays/intel-legacy-overlay)
  ];
}
