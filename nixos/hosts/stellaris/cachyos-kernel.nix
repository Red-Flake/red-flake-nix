{ lib, pkgs, inputs, ... }:

{
  # NOTE: Requires an x86-64-v3 capable CPU (otherwise the system may not boot).
  #
  # Important: We intentionally do NOT enable Mrn157/CachyNix as a global overlay, because that
  # overlay overrides many unrelated packages and can force large from-source rebuilds.
  #
  # We also need unfree drivers (NVIDIA), so we create a small dedicated pkgs instance with
  # CachyNix's overlay + allowUnfree enabled, and use it only for `boot.kernelPackages`.
  boot.kernelPackages =
    let
      cachyPkgs = import inputs.cachynix.inputs.nixpkgs {
        inherit (pkgs) system;
        overlays = [ inputs.cachynix.overlays.default ];
        config = {
          allowUnfree = true;
          nvidia.acceptLicense = true;
        };
      };
      cachyKernel =
        (cachyPkgs.linuxPackages_cachyos-lto.cachyOverride { mArch = "GENERIC_V3"; }).kernel;
      baseKernelPackages = pkgs.linuxPackagesFor cachyKernel;
      patchedNvidiaPackages =
        baseKernelPackages.nvidiaPackages
        // {
          latest = baseKernelPackages.nvidiaPackages.latest.overrideAttrs (old: {
            passthru =
              (old.passthru or { })
              // {
                settings = old.passthru.settings.overrideAttrs (sOld: {
                  nativeBuildInputs = (sOld.nativeBuildInputs or [ ]) ++ [ pkgs.binutils ];
                  makeFlags = (sOld.makeFlags or [ ]) ++ [ "STRIP=${pkgs.binutils}/bin/strip" ];
                });
              };
          });
        };
    in
    # Wrap the cached CachyOS kernel with *this* system's linuxPackages set so we don't
      # drag CachyNix's full package universe into the host closure.
    lib.mkForce (baseKernelPackages // { nvidiaPackages = patchedNvidiaPackages; });
}
