{ inputs, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    #linuxKernel.packages.linux_xanmod_latest.turbostat
    intel-gpu-tools
    (pkgs.callPackage (inputs.redflake-packages + "/pkgs/outline-electron/package.nix") {
      electron = pkgs.electron_44;
    })
    # ucc itself is installed by services.uccd (the module adds its package,
    # built from the host nixpkgs, to systemPackages).
    nvtopPackages.full
  ];

  programs.localsend.enable = true;
}
