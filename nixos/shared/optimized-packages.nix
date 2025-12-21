# Highly optimized package loading with lazy evaluation
{ lib
, hostType ? "security"
, useTags ? [ ]
, ...
}:
let
  # Core packages needed by all systems
  corePackages = [
    ../modules/packages/general.nix
    ../modules/packages/nixos.nix
    ../modules/packages/vcs.nix
    ../modules/packages/editors.nix
  ];

  # Development packages (lightweight)
  devPackages = [
    ../modules/packages/dev.nix
  ];

  # Desktop packages grouped by weight
  lightDesktopPackages = [
    ../modules/packages/browsers.nix
    ../modules/packages/chat.nix
  ];

  heavyDesktopPackages = [
    ../modules/packages/multimedia.nix
    ../modules/packages/office.nix
    ../modules/packages/wine.nix
    ../modules/packages/distrobox.nix
  ];

  # Security packages grouped by specialization
  basicSecurityPackages = [
    ../modules/packages/recon.nix
    ../modules/packages/smb.nix
    ../modules/packages/remote-access.nix
  ];

  webSecurityPackages = [
    ../modules/packages/web-related.nix
    ../modules/packages/cms.nix
    ../modules/packages/dns.nix
  ];

  adSecurityPackages = [
    ../modules/packages/database.nix
    ../modules/packages/creds.nix
    ../modules/packages/windows.nix
  ];

  advancedSecurityPackages = [
    ../modules/packages/rev.nix
    ../modules/packages/mobile.nix
    ../modules/packages/forensics.nix
    ../modules/packages/stego.nix
    ../modules/packages/crypto.nix
  ];

  exploitPackages = [
    ../modules/packages/bruteforce.nix
    ../modules/packages/pwn.nix
    ../modules/packages/exploitation.nix
    ../modules/packages/vulnerability-scanners.nix
    ../modules/packages/c2.nix
  ];

  networkingPackages = [
    ../modules/packages/wireless.nix
    ../modules/packages/sniffer.nix
    ../modules/packages/mitm.nix
    ../modules/packages/pivoting.nix
  ];

  specialtyPackages = [
    ../modules/packages/wordlists.nix
    ../modules/packages/hashes.nix
    ../modules/packages/social-engineering.nix
    ../modules/packages/smtp.nix
    ../modules/packages/command-injection.nix
    ../modules/packages/file-transfer.nix
    ../modules/packages/cloud.nix
    ../modules/packages/snmp.nix
  ];

  # Conditional package loading based on tags
  conditionalPackages =
    tags:
    lib.optionals (builtins.elem "basic-security" tags) basicSecurityPackages
    ++ lib.optionals (builtins.elem "web-security" tags) webSecurityPackages
    ++ lib.optionals (builtins.elem "ad-security" tags) adSecurityPackages
    ++ lib.optionals (builtins.elem "advanced-security" tags) advancedSecurityPackages
    ++ lib.optionals (builtins.elem "exploit" tags) exploitPackages
    ++ lib.optionals (builtins.elem "networking" tags) networkingPackages
    ++ lib.optionals (builtins.elem "specialty" tags) specialtyPackages
    ++ lib.optionals (builtins.elem "light-desktop" tags) lightDesktopPackages
    ++ lib.optionals (builtins.elem "heavy-desktop" tags) heavyDesktopPackages;
in
{
  imports =
    corePackages ++ (lib.optionals (hostType != "server") devPackages) ++ (conditionalPackages useTags);

  # Pre-defined package sets for common configurations
  packageSets = {
    full-security = [
      "basic-security"
      "web-security"
      "ad-security"
      "advanced-security"
      "exploit"
      "networking"
      "specialty"
      "light-desktop"
      "heavy-desktop"
    ];
    web-pentest = [
      "basic-security"
      "web-security"
      "exploit"
      "light-desktop"
    ];
    ad-pentest = [
      "basic-security"
      "ad-security"
      "exploit"
      "light-desktop"
    ];
    forensics = [
      "basic-security"
      "advanced-security"
      "light-desktop"
    ];
    desktop-dev = [
      "light-desktop"
      "heavy-desktop"
    ];
    minimal-server = [ ];
  };
}
