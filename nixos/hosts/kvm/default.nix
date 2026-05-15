# KVM host-specific configuration
{
  imports = [
    ./hardware.nix
  ];

  # VMs don't benefit from x86_64-v3 target optimization
  custom.kernel.cachyos.target = "generic";

  # Standard sysctl profile for VMs
  custom.sysctl = {
    enable = true;
    profile = "standard";
    ramGB = 8;
    swappiness = 1;
    qdisc = "fq";
  };
}
