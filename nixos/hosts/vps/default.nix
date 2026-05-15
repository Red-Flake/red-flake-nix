# VPS host-specific configuration
{
  imports = [
    ./hardware.nix
    ./networking.nix
    ./packages.nix
    ./services.nix
  ];

  # VPS don't benefit from x86_64-v3 target optimization
  custom.kernel.cachyos.target = "generic";

  # Standard sysctl profile for VPS with core dumps disabled
  custom.sysctl = {
    enable = true;
    profile = "standard";
    ramGB = 8;
    swappiness = 1;
    qdisc = "fq";
    disableCoreDumps = true;
  };
}
