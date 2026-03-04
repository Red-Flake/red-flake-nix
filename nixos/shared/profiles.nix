# NixOS configuration profiles for different host types
# hostType is passed via specialArgs from flake.nix
{ lib
, pkgs
, ...
}:
{
  # Full security/penetration testing configuration
  security = {
    imports = [
      # Base configuration
      ./base.nix

      # Security-specific modules
      ../modules/setup-burp.nix
      ../modules/setup-neo4j.nix
      ../modules/wireshark.nix
      ../modules/proxies.nix

      # Red team tools and resources
      ../modules/wordlists.nix
      ../modules/webshells.nix
      ../modules/payloads.nix
      ../modules/exploits.nix
      ../modules/tools.nix
      ../modules/metasploit.nix
    ];

    # Set host type option (so other modules can query it)
    custom.hostType = lib.mkDefault "security";
  };

  # Minimal server configuration
  server = {
    imports = [
      ./base.nix
    ];

    # Set host type option
    custom.hostType = lib.mkDefault "server";

    # Disable unnecessary services for servers
    services.xserver.enable = lib.mkForce false;
    services.desktopManager.plasma6.enable = lib.mkForce false;

    # Disable packages not needed for servers
    environment.systemPackages = lib.mkForce (
      with pkgs;
      [
        # Minimal server packages only
        netcat-gnu
        file
        tree
        wget
        zip
        unzip
        htop
        fastfetch
        zsh
        openvpn
        jq
        redis
        lsd
        bat
        man
        less
      ]
    );
  };

  # Desktop workstation (non-security)
  desktop = {
    imports = [
      ./base.nix
    ];

    # Set host type option
    custom.hostType = lib.mkDefault "desktop";
  };
}
