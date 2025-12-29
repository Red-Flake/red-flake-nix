{ config
, lib
, pkgs
, ...
}:

# This module wraps the bootloader installation to support a read-only /boot partition.
# It remounts /boot read-write before installation and read-only after.
#
# How it works:
# 1. /boot is mounted read-write in fstab (normal)
# 2. After boot, boot-readonly.service remounts /boot read-only
# 3. During nixos-rebuild, our wrapped installBootLoader:
#    - Remounts /boot read-write
#    - Runs the actual grub installation (perl script)
#    - Runs extraInstallCommands (including our grub.cfg fix)
#    - Remounts /boot read-only

let
  cfg = config.boot.loader.grub;
  inherit (config.boot.loader) efi;

  # Replicate grub module's internal logic for building the install script
  grubPkgs = if cfg.forcei686 then pkgs.pkgsi686Linux else pkgs;

  realGrub =
    if cfg.zfsSupport then
      grubPkgs.grub2.override
        {
          zfsSupport = true;
          zfs = cfg.zfsPackage;
        }
    else
      grubPkgs.grub2;

  grub = if cfg.devices == [ "nodev" ] then null else realGrub;
  grubEfiPkg = if cfg.efiSupport then realGrub.override { inherit (cfg) efiSupport; } else null;

  # Build the grubConfig XML generator (same as grub.nix)
  grubConfig = args:
    let
      efiSysMountPoint = if args.efiSysMountPoint == null then args.path else args.efiSysMountPoint;
      efiSysMountPoint' = builtins.replaceStrings [ "/" ] [ "-" ] efiSysMountPoint;
    in
    pkgs.writeText "grub-config.xml" (
      builtins.toXML {
        splashImage = lib.optionalString (cfg.splashImage != null) cfg.splashImage;
        splashMode = lib.optionalString (cfg.splashMode != null) cfg.splashMode;
        backgroundColor = lib.optionalString (cfg.backgroundColor != null) cfg.backgroundColor;
        entryOptions = lib.optionalString (cfg.entryOptions != null) cfg.entryOptions;
        subEntryOptions = lib.optionalString (cfg.subEntryOptions != null) cfg.subEntryOptions;
        grub = lib.optionalString ((grub.grubTarget or "") != "") (toString grub);
        grubTarget = lib.optionalString (grub != null) (grub.grubTarget or "");
        shell = "${pkgs.runtimeShell}";
        fullName = lib.getName realGrub;
        fullVersion = lib.getVersion realGrub;
        grubEfi = lib.optionalString (grubEfiPkg != null) (toString grubEfiPkg);
        grubTargetEfi = lib.optionalString cfg.efiSupport (if grubEfiPkg != null then grubEfiPkg.grubTarget or "" else "");
        bootPath = args.path;
        inherit (config.boot.loader.grub) storePath;
        bootloaderId =
          if args.efiBootloaderId == null then
            "${config.system.nixos.distroName}${efiSysMountPoint'}"
          else
            args.efiBootloaderId;
        timeout = if config.boot.loader.timeout == null then -1 else config.boot.loader.timeout;
        theme = lib.optionalString (cfg.theme != null) cfg.theme;
        inherit efiSysMountPoint;
        inherit (args) devices;
        inherit (efi) canTouchEfiVariables;
        inherit (cfg)
          extraConfig
          extraPerEntryConfig
          extraEntries
          forceInstall
          useOSProber
          extraGrubInstallArgs
          extraEntriesBeforeNixOS
          extraPrepareConfig
          configurationLimit
          copyKernels
          default
          fsIdentifier
          efiSupport
          efiInstallAsRemovable
          gfxmodeEfi
          gfxmodeBios
          gfxpayloadEfi
          gfxpayloadBios
          users
          timeoutStyle
          ;
        path = with pkgs; lib.makeBinPath (
          [
            coreutils
            gnused
            gnugrep
            findutils
            diffutils
            btrfs-progs
            util-linux
            mdadm
          ]
          ++ lib.optional cfg.efiSupport efibootmgr
          ++ lib.optionals cfg.useOSProber [
            busybox
            os-prober
          ]
        );
        font = lib.optionalString (cfg.font != null) cfg.font;
      }
    );

  # Build install-grub.pl with substitutions
  install-grub-pl = pkgs.replaceVars
    "${pkgs.path}/nixos/modules/system/boot/loader/grub/install-grub.pl"
    {
      utillinux = pkgs.util-linux;
      btrfsprogs = pkgs.btrfs-progs;
      inherit (config.system.nixos) distroName;
      bootPath = null;
      bootRoot = null;
    };

  # Perl with required packages
  perl = pkgs.perl.withPackages (p: with p; [
    FileSlurp
    FileCopyRecursive
    XMLLibXML
    XMLSAX
    XMLSAXBase
    ListCompare
    JSON
  ]);

in
{
  config = lib.mkIf cfg.enable {

    # Override the bootloader installer with our wrapper
    system.build.installBootLoader = lib.mkForce (
      pkgs.writeScript "install-grub-wrapped.sh" ''
        #!${pkgs.runtimeShell}
        set -e

        # Step 1: Remount /boot read-write
        echo "Remounting /boot read-write for bootloader installation..."
        ${pkgs.util-linux}/bin/mount -o remount,rw /boot || true

        # Step 2: Run the actual GRUB installation
        ${lib.optionalString cfg.enableCryptodisk "export GRUB_ENABLE_CRYPTODISK=y"}
        ${lib.concatMapStrings (args: ''
          ${perl}/bin/perl ${install-grub-pl} ${grubConfig args} "$@"
        '') cfg.mirroredBoots}

        # Step 3: Run extra install commands (grub.cfg fixes, etc.)
        ${cfg.extraInstallCommands}

        # Step 4: Sync and remount /boot read-only
        echo "Syncing and remounting /boot read-only..."
        ${pkgs.coreutils}/bin/sync
        ${pkgs.util-linux}/bin/mount -o remount,ro /boot
      ''
    );

    # Systemd service to remount /boot read-only after boot completes.
    # This protects /boot from corruption during forced shutdowns.
    systemd.services.boot-readonly = {
      description = "Remount /boot read-only";
      wantedBy = [ "multi-user.target" ];
      after = [ "local-fs.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.util-linux}/bin/mount -o remount,ro /boot";
        RemainAfterExit = true;
      };
    };

  };
}
