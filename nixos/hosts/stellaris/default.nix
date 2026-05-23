# TUXEDO Stellaris host-specific configuration
{ lib, ... }:
{
  imports = [
    ./hardware.nix
    ./performance.nix
    ./avatar.nix
    ./gaming.nix
    ./nvidia.nix
    ./ollama.nix
    ./on-demand-services.nix
    ./packages.nix
  ];

  # Use tmpfs for /tmp instead of ZFS — 96 GB RAM is plenty
  fileSystems."/tmp" = lib.mkForce {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "defaults"
      "size=16G"
      "mode=1777"
    ];
  };

  # Workstation sysctl profile with all optimizations enabled
  custom.sysctl = {
    enable = true;
    profile = "workstation";
    ramGB = 96;
    swappiness = 100; # High swappiness for ZRAM
    qdisc = "cake";
    enableZRAMOptimizations = true;
    enableGamingTweaks = true;
    enableTransparentHugepages = true;
    enableAdvancedNetworking = true;
    enableSecurityHardening = true;
  };
}
