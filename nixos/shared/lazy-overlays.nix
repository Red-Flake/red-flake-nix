# Lazy-loaded overlay system for optimal performance
{ inputs, lib, hostType ? "security", ... }:
let
  # Group overlays by loading priority and frequency
  criticalOverlays = [
    inputs.chaotic.overlays.default
    (import ../overlays/impacket-overlay)
  ];

  # Security overlays grouped by tool category - only load what's needed
  reconOverlays = [
    (import ../overlays/nmapAutomator-overlay)
    (import ../overlays/eyewitness-overlay)
    (import ../overlays/aquatone-overlay)
  ];

  webOverlays = [
    (import ../overlays/droopescan-overlay)
    (import ../overlays/joomla-brute-overlay)
  ];

  adOverlays = [
    (import ../overlays/netexec-overlay)
    (import ../overlays/bloodhound-quickwin-overlay)
    (import ../overlays/ldapdomaindump-overlay)
    (import ../overlays/kerbrute-overlay)
    (import ../overlays/pyGPOAbuse-overlay)
    (import ../overlays/powerview-py-overlay)
    (import ../overlays/linWinPwn-overlay)
  ];

  exploitOverlays = [
    (import ../overlays/evil-winrm-overlay)
    (import ../overlays/sliver-overlay)
    (import ../overlays/responder-overlay)
    (import ../overlays/ntlm_theft-overlay)
  ];

  miscSecurityOverlays = [
    (import ../overlays/certipy-overlay)
    (import ../overlays/social-engineer-toolkit)
    (import ../overlays/cupp-overlay)
    (import ../overlays/wordlists-overlay)
    (import ../overlays/john-overlay)
    (import ../overlays/bashfuscator-overlay)
    (import ../overlays/dnscat2-overlay)
    (import ../overlays/smtp-user-enum-overlay)
    (import ../overlays/spose-overlay)
    (import ../overlays/username-anarchy-overlay)
    (import ../overlays/wmiexec-Pro-overlay)
  ];

  desktopOverlays = [
    (import ../overlays/freerdp3-overlay)
    (import ../overlays/intel-legacy-overlay)
  ];

  # Function to conditionally load overlay groups
  conditionalOverlays = tags:
    lib.optionals (builtins.elem "recon" tags) reconOverlays ++
    lib.optionals (builtins.elem "web" tags) webOverlays ++
    lib.optionals (builtins.elem "ad" tags) adOverlays ++
    lib.optionals (builtins.elem "exploit" tags) exploitOverlays ++
    lib.optionals (builtins.elem "misc-security" tags) miscSecurityOverlays ++
    lib.optionals (builtins.elem "desktop" tags) desktopOverlays;
in
{
  # Optimized overlay loading based on host type and usage tags
  getOverlaysFor = hostType: usageTags:
    let
      base = criticalOverlays;
      conditional = conditionalOverlays usageTags;
    in
    if hostType == "server" then base
    else if hostType == "desktop" then base ++ desktopOverlays
    else base ++ conditional; # security gets what it needs based on tags

  # Pre-defined tag sets for common use cases
  commonTagSets = {
    full-security = [ "recon" "web" "ad" "exploit" "misc-security" "desktop" ];
    web-security = [ "recon" "web" "misc-security" ];
    ad-security = [ "recon" "ad" "exploit" ];
    minimal-security = [ "recon" "exploit" ];
  };
}