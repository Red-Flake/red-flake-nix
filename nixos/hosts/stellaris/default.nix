# TUXEDO Stellaris host-specific configuration
{
  imports = [
    ./hardware.nix
    ./sysctl.nix
    ./performance.nix
    #./xanmod.nix
    ./avatar.nix
    ./gaming.nix
    ./nvidia.nix
    ./ollama.nix
    ./on-demand-services.nix
    ./packages.nix
  ];
}
