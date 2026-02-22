# Borg host-specific configuration
{
  imports = [
    ./hardware.nix
    ./sysctl.nix
    ./cachyos-kernel.nix
    ./packages.nix
  ];
}
