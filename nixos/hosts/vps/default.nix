# VPS host-specific configuration
{
  imports = [
    ./hardware.nix
    ./networking.nix
    ./packages.nix
    ./services.nix
  ];
  
}