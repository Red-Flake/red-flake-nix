{ config
, lib
, pkgs
, pkgsUnstable
, inputs
, ...
}:
let
  cfg = config.custom.kernel;

  # ZFS 2.4 for CachyOS kernels: use pre-built kernel module + userspace from nix-cachyos-kernel
  # The exported package is the kernel module; passthru.userspaceTools is the matching userspace
  cachyosZfsModule =
    let
      exported = inputs.nix-cachyos-kernel.packages.${pkgs.system};
      attrName = if cfg.cachyos.lto then "zfs-cachyos-lto" else "zfs-cachyos";
    in
    if builtins.hasAttr attrName exported then
      builtins.getAttr attrName exported
    else
      throw ''
        CachyOS ZFS package "${attrName}" was not found in:
          inputs.nix-cachyos-kernel.packages.${pkgs.system}

        Available attrs:
          ${lib.concatStringsSep ", " (builtins.attrNames exported)}
      '';

  withZfs24 =
    kernelPackages:
    if cfg.flavor == "cachyos" then
      kernelPackages.extend
        (_self: _super: {
          # NixOS looks up the kernel module via boot.zfs.package.kernelModuleAttribute ("zfs_2_4")
          zfs_2_4 = cachyosZfsModule;
        })
    else
      kernelPackages.extend (_self: _super: {
        zfs_2_4 = pkgsUnstable.zfs_2_4.override {
          configFile = "kernel";
          inherit (kernelPackages) kernel;
        };
      });

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
      ltoSuffix = if cfg.cachyos.lto then "-lto" else "";
      targetSuffix =
        if cfg.cachyos.target == "generic" then
          ""
        else
          "-${cfg.cachyos.target}";
    in
    "linux-cachyos-${cfg.cachyos.variant}${ltoSuffix}${targetSuffix}";

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

  # Apply ZFS 2.4 and optionally NVIDIA strip fix
  selectedKernelPackagesWithZfs = withZfs24 selectedKernelPackagesBase;

  selectedKernelPackages =
    if cfg.nvidia.stripFix.enable then
      withNvidiaStripFix selectedKernelPackagesWithZfs
    else
      selectedKernelPackagesWithZfs;

  # Userspace ZFS package — must match the kernel module version
  # The cachyos ZFS module is 2.4.2, same as pkgsUnstable.zfs_2_4
  zfsPackage = pkgsUnstable.zfs_2_4;
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

    cachyos.variant = lib.mkOption {
      type = lib.types.enum [
        "lts"
        "latest"
        "bore"
        "bmq"
        "eevdf"
        "rt-bore"
        "hardened"
        "server"
        "deckify"
        "rc"
      ];
      default = "bore";
      description = ''
        CachyOS kernel variant to use when custom.kernel.flavor = "cachyos".

        lts      -> Long-term support kernel (6.18.x)
        latest   -> Latest stable kernel (7.0.x)
        bore     -> BORE scheduler, best for desktop/gaming (7.0.x)
        bmq      -> BitMap Queue scheduler (7.0.x)
        eevdf    -> Earliest Eligible Virtual Deadline First scheduler (7.0.x)
        rt-bore  -> Real-time kernel with BORE scheduler (7.0.x)
        hardened -> Security-hardened kernel (6.19.x)
        server   -> Server-optimized kernel (7.0.x)
        deckify  -> Steam Deck optimized kernel (7.0.x)
        rc       -> Release candidate kernel (7.1-rcX)

        Note: not all variant + target combinations exist.
        The module will error with available options if a combination is invalid.
      '';
    };

    cachyos.lto = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable Clang ThinLTO variant for better runtime performance.
        Not all variant + lto combinations may exist.
      '';
    };

    cachyos.target = lib.mkOption {
      type = lib.types.enum [
        "generic"
        "x86_64-v2"
        "x86_64-v3"
        "x86_64-v4"
        "zen4"
      ];
      default = "x86_64-v3";
      description = ''
        CachyOS kernel target optimization to use when custom.kernel.flavor = "cachyos".

        generic     -> linux-cachyos-{variant}[-lto]
        x86_64-v2   -> linux-cachyos-{variant}[-lto]-x86_64-v2
        x86_64-v3   -> linux-cachyos-{variant}[-lto]-x86_64-v3
        x86_64-v4   -> linux-cachyos-{variant}[-lto]-x86_64-v4
        zen4        -> linux-cachyos-{variant}[-lto]-zen4

        Note: not all variant + target combinations exist (e.g. hardened has no target suffixes).
        The module will error with available options if a combination is invalid.
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
    boot.zfs.package = lib.mkDefault zfsPackage;
  };
}
