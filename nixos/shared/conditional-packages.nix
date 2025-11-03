# Conditional package loading based on host type
{ lib, hostType ? "security", ... }:
let
  # Base packages needed by all hosts
  baseModules = [
    ../modules/packages/general.nix
    ../modules/packages/nixos.nix
    ../modules/packages/vcs.nix
    ../modules/packages/editors.nix
    ../modules/packages/dev.nix
  ];

  # Security-specific package modules
  securityModules = [
    ../modules/packages/recon.nix
    ../modules/packages/smb.nix
    ../modules/packages/database.nix
    ../modules/packages/rev.nix
    ../modules/packages/mobile.nix
    ../modules/packages/bruteforce.nix
    ../modules/packages/wireless.nix
    ../modules/packages/wordlists.nix
    ../modules/packages/cms.nix
    ../modules/packages/sniffer.nix
    ../modules/packages/mitm.nix
    ../modules/packages/smtp.nix
    ../modules/packages/pwn.nix
    ../modules/packages/crypto.nix
    ../modules/packages/hashes.nix
    ../modules/packages/social-engineering.nix
    ../modules/packages/forensics.nix
    ../modules/packages/stego.nix
    ../modules/packages/pivoting.nix
    ../modules/packages/command-injection.nix
    ../modules/packages/windows.nix
    ../modules/packages/web-related.nix
    ../modules/packages/dns.nix
    ../modules/packages/file-transfer.nix
    ../modules/packages/exploitation.nix
    ../modules/packages/vulnerability-scanners.nix
    ../modules/packages/creds.nix
    ../modules/packages/cloud.nix
    ../modules/packages/snmp.nix
    ../modules/packages/c2.nix
  ];

  # Desktop/multimedia packages
  desktopModules = [
    ../modules/packages/browsers.nix
    ../modules/packages/chat.nix
    ../modules/packages/multimedia.nix
    ../modules/packages/office.nix
    ../modules/packages/remote-access.nix
    ../modules/packages/wine.nix
    ../modules/packages/distrobox.nix
  ];

  # Server packages (minimal)
  serverModules = [
    # Only essential packages for servers
  ];
in
{
  imports = baseModules ++ 
    (lib.optionals (hostType == "security") securityModules) ++
    (lib.optionals (builtins.elem hostType ["security" "desktop"]) desktopModules) ++
    (lib.optionals (hostType == "server") serverModules);
}