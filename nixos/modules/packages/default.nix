# packages

{ inputs, config, lib, pkgs, modulesPath, ... }:

{
  # disable default packages
  environment.defaultPackages = [ ];

  imports = [
    # General programs
    ./general.nix

    # NixOS related programs
    ./nixos.nix

    # Version Control Systems
    ./vcs.nix

    # Code editors
    ./editors.nix

    # Web browsers
    ./browsers.nix

    # Chat programs
    ./chat.nix

    # Development oriented tools
    ./dev.nix

    # Multimedia programs
    ./multimedia.nix

    # Office programs
    ./office.nix

    # Reconnaissance tools
    ./recon.nix

    # SMB tools
    ./smb.nix

    # Database related programs
    ./database.nix

    # Reversing programs
    ./rev.nix

    # Mobile attack related programs
    ./mobile.nix

    # Bruteforce tools
    ./bruteforce.nix

    # Wireless attack tools
    ./wireless.nix

    # Wordlists and wordlist-related tools
    ./wordlists.nix

    # CMS attack tools
    ./cms.nix

    # Network sniffers
    ./sniffer.nix

    # Man-in-the-Middle related tools
    ./mitm.nix

    # SMTP tools
    ./smtp.nix

    # Remote Access programs
    ./remote-access.nix

    # Pwn related programs
    ./pwn.nix

    # Crypto related programs
    ./crypto.nix

    # Hash related tools
    ./hashes.nix

    # Social Engineering tools
    ./social-engineering.nix

    # Digital forensics tools
    ./forensics.nix

    # Steganography tools
    ./stego.nix

    # Wine
    ./wine.nix

    # Pivoting programs
    ./pivoting.nix

    # Distrobox
    ./distrobox.nix

    # Command injection related tools
    ./command-injection.nix

    # Windows related tools
    ./windows.nix

    # Web related tools
    ./web-related.nix

    # DNS tools
    ./dns.nix

    # Programs for file transfer
    ./file-transfer.nix

    # Exploitation tools
    ./exploitation.nix

    # Vulnerability scanning tools
    ./vulnerability-scanners.nix

    # Credential related tools
    ./creds.nix

    # Cloud related tools
    ./cloud.nix

    # SNMP tools
    ./snmp.nix

    # C2 frameworks
    ./c2.nix
  ];
}
