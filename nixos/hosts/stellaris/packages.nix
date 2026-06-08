{ inputs, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    #linuxKernel.packages.linux_xanmod_latest.turbostat
    intel-gpu-tools
    (pkgs.callPackage (inputs.redflake-packages + "/pkgs/outline-electron/package.nix") {
      inherit (pkgs) electron_39;
    })
    inputs.ucc.packages.x86_64-linux.ucc
    nvtopPackages.full
  ];

  programs.localsend.enable = true;
}
