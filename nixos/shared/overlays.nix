# Consolidated overlay groups for better performance
{ inputs, ... }:
{
  # Core overlays that all hosts need
  core = [
    inputs.chaotic.overlays.default
    (import ../overlays/impacket-overlay)
  ];

  # Security/pentesting overlays - only load for security hosts
  security = [
    (import ../overlays/netexec-overlay)
    (import ../overlays/evil-winrm-overlay)
    (import ../overlays/bloodhound-quickwin-overlay)
    (import ../overlays/certipy-overlay)
    (import ../overlays/responder-overlay)
    (import ../overlays/sliver-overlay)
    (import ../overlays/ldapdomaindump-overlay)
    (import ../overlays/kerbrute-overlay)
    (import ../overlays/pyGPOAbuse-overlay)
    (import ../overlays/powerview-py-overlay)
    (import ../overlays/linWinPwn-overlay)
    (import ../overlays/ntlm_theft-overlay)
    (import ../overlays/social-engineer-toolkit)
    (import ../overlays/cupp-overlay)
    (import ../overlays/wordlists-overlay)
    (import ../overlays/john-overlay)
    (import ../overlays/droopescan-overlay)
    (import ../overlays/joomla-brute-overlay)
    (import ../overlays/eyewitness-overlay)
    (import ../overlays/aquatone-overlay)
    (import ../overlays/bashfuscator-overlay)
    (import ../overlays/dnscat2-overlay)
    (import ../overlays/smtp-user-enum-overlay)
    (import ../overlays/nmapAutomator-overlay)
    (import ../overlays/spose-overlay)
    (import ../overlays/username-anarchy-overlay)
    (import ../overlays/wmiexec-Pro-overlay)
  ];

  # Desktop-specific overlays
  desktop = [
    (import ../overlays/freerdp3-overlay)
    (import ../overlays/intel-legacy-overlay)
  ];

  # Helper function to get overlays for a host type
  getOverlaysFor = hostType:
    let
      baseOverlays = core;
      securityOverlays = if (hostType == "security") then security else [];
      desktopOverlays = if (builtins.elem hostType ["security" "desktop"]) then desktop else [];
    in
    baseOverlays ++ securityOverlays ++ desktopOverlays;
}