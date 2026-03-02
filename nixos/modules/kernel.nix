{ config
, lib
, pkgs
, inputs
, ...
}:
let
  cfg = config.custom.kernel;

  withNvidiaStripFix =
    kernelPackages:
    if !(kernelPackages ? nvidiaPackages) || !(kernelPackages.nvidiaPackages ? latest) then
      kernelPackages
    else
      let
        latestDrv = kernelPackages.nvidiaPackages.latest.overrideAttrs (old: {
          passthru =
            (old.passthru or { })
            // lib.optionalAttrs (lib.hasAttrByPath [ "passthru" "settings" ] old) {
              settings = old.passthru.settings.overrideAttrs (sOld: {
                nativeBuildInputs = (sOld.nativeBuildInputs or [ ]) ++ [ pkgs.binutils ];
                makeFlags = (sOld.makeFlags or [ ]) ++ [ "STRIP=${pkgs.binutils}/bin/strip" ];
              });
            };
        });
      in
      kernelPackages
      // {
        nvidiaPackages = kernelPackages.nvidiaPackages // { latest = latestDrv; };
      };

  cachyPkgs = import inputs.nix-cachyos-kernel.inputs.nixpkgs {
    inherit (pkgs.stdenv.hostPlatform) system;
    overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
    config = {
      allowUnfree = pkgs.config.allowUnfree or true;
      nvidia.acceptLicense = (pkgs.config.nvidia or { }).acceptLicense or false;
    };
  };

  # stick to LTS kernel for ZFS and stable nixpkgs
  # NOTE: `linuxPackagesFor` expects a kernel derivation (with `.override`), not a linuxPackages set.
  cachyKernel = cachyPkgs.cachyosKernels.linuxPackages-cachyos-lts.kernel;

  cachyBaseKernelPackages = pkgs.linuxPackagesFor cachyKernel;

  xanmodKernelPackages =
    pkgs.linuxPackages_xanmod_latest or (
      pkgs.linuxPackages_xanmod or (throw "custom.kernel.flavor = \"xanmod\" is not available in this nixpkgs")
    );

  selectedKernelPackagesBase =
    if cfg.flavor == "cachyos" then
      cachyBaseKernelPackages
    else if cfg.flavor == "xanmod" then
      xanmodKernelPackages
    else
      pkgs.linuxPackages;

  selectedKernelPackages =
    if cfg.nvidia.stripFix.enable then
      withNvidiaStripFix selectedKernelPackagesBase
    else
      selectedKernelPackagesBase;
in
{
  options.custom.kernel = {
    flavor = lib.mkOption {
      type = lib.types.enum [
        "cachyos"
        "xanmod"
        "default"
      ];
      default = "cachyos";
      description = "Kernel flavor to use system-wide by default.";
    };

    nvidia.stripFix.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Apply a small build fix for NVIDIA driver settings (adds `strip` to PATH during build).";
    };
  };

  config = {
    boot.kernelPackages = lib.mkDefault selectedKernelPackages;
  };
}
