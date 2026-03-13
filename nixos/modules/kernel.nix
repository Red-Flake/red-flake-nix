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
      kernelPackages // {
        nvidiaPackages = kernelPackages.nvidiaPackages // {
          latest = latestDrv;
        };
      };

  cachyKernelAttrName =
    let
      suffix =
        if cfg.cachyos.target == "generic" then
          ""
        else
          "-${cfg.cachyos.target}";
    in
    "linux-cachyos-lts${suffix}";

  cachyKernel =
    let
      exported = inputs.nix-cachyos-kernel.packages.${pkgs.system};
    in
    if builtins.hasAttr cachyKernelAttrName exported then
      builtins.getAttr cachyKernelAttrName exported
    else
      throw ''
        Requested CachyOS kernel "${cachyKernelAttrName}" was not found in:
          inputs.nix-cachyos-kernel.packages.${pkgs.system}

        Available attrs:
          ${lib.concatStringsSep ", " (builtins.attrNames exported)}
      '';

  cachyBaseKernelPackages = pkgs.linuxPackagesFor cachyKernel;

  xanmodKernelPackages =
    pkgs.linuxPackages_xanmod_latest or (
      pkgs.linuxPackages_xanmod or
        (throw "custom.kernel.flavor = \"xanmod\" is not available in this nixpkgs")
    );

  defaultKernelPackages = pkgs.linuxPackages;

  selectedKernelPackagesBase =
    if cfg.flavor == "cachyos" then
      cachyBaseKernelPackages
    else if cfg.flavor == "xanmod" then
      xanmodKernelPackages
    else
      defaultKernelPackages;

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

    cachyos.target = lib.mkOption {
      type = lib.types.enum [
        "generic"
        "x86_64-v2"
        "x86_64-v3"
        "x86_64-v4"
        "zen4"
      ];
      default = "generic";
      description = ''
        CachyOS kernel target variant to use when custom.kernel.flavor = "cachyos".

        generic     -> linux-cachyos-lts
        x86_64-v2   -> linux-cachyos-lts-x86_64-v2
        x86_64-v3   -> linux-cachyos-lts-x86_64-v3
        x86_64-v4   -> linux-cachyos-lts-x86_64-v4
        zen4        -> linux-cachyos-lts-zen4
      '';
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
