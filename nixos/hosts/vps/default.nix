# VPS host-specific configuration
{
  imports = [
    ./hardware.nix
    ./sysctl.nix
    ./networking.nix
    ./packages.nix
    ./services.nix
  ];

}
