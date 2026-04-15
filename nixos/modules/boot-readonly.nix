{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.boot.loader.systemd-boot;
  inherit (config.boot.loader) efi;

  systemdBootBuilder = pkgs.replaceVarsWith {
    name = "systemd-boot";
    dir = "bin";
    src = "${pkgs.path}/nixos/modules/system/boot/loader/systemd-boot/systemd-boot-builder.py";
    isExecutable = true;
    replacements = rec {
      inherit (builtins) storeDir;
      inherit (pkgs) python3;

      systemd = config.systemd.package;
      bootspecTools = config.boot.bootspec.package;
      nix = config.nix.package.out;

      timeout = if config.boot.loader.timeout == null then "menu-force" else config.boot.loader.timeout;
      configurationLimit = if cfg.configurationLimit == null then 0 else cfg.configurationLimit;

      inherit (cfg)
        consoleMode
        graceful
        editor
        rebootForBitlocker
        ;

      inherit (efi) efiSysMountPoint canTouchEfiVariables;

      bootMountPoint =
        if cfg.xbootldrMountPoint != null then cfg.xbootldrMountPoint else efi.efiSysMountPoint;

      nixosDir = "/EFI/nixos";
      inherit (config.system.nixos) distroName;

      checkMountpoints = pkgs.writeShellScript "check-mountpoints" ''
        fail() {
          echo "$1 = '$2' is not a mounted partition. Is the path configured correctly?" >&2
          exit 1
        }
        ${pkgs.util-linuxMinimal}/bin/findmnt ${efiSysMountPoint} > /dev/null || fail efiSysMountPoint ${efiSysMountPoint}
        ${lib.optionalString (cfg.xbootldrMountPoint != null)
          "${pkgs.util-linuxMinimal}/bin/findmnt ${cfg.xbootldrMountPoint} > /dev/null || fail xbootldrMountPoint ${cfg.xbootldrMountPoint}"
        }
      '';

      copyExtraFiles = pkgs.writeShellScript "copy-extra-files" ''
        ${lib.concatStrings (
          lib.mapAttrsToList (n: v: ''
            ${pkgs.coreutils}/bin/install -Dp "${v}" "${bootMountPoint}/"${lib.escapeShellArg n}
            ${pkgs.coreutils}/bin/install -D /dev/null "${bootMountPoint}/${nixosDir}/.extra-files/"${lib.escapeShellArg n}
          '') cfg.extraFiles
        )}

        ${lib.concatStrings (
          lib.mapAttrsToList (n: v: ''
            ${pkgs.coreutils}/bin/install -Dp "${pkgs.writeText n v}" "${bootMountPoint}/loader/entries/"${lib.escapeShellArg n}
            ${pkgs.coreutils}/bin/install -D /dev/null "${bootMountPoint}/${nixosDir}/.extra-files/loader/entries/"${lib.escapeShellArg n}
          '') cfg.extraEntries
        )}
      '';
    };
  };

in
{
  config = lib.mkIf cfg.enable {

    # Keep /boot read-only outside of bootloader installs. For systemd-boot we
    # wrap nixpkgs' builder rather than reimplementing a separate install flow.
    system.build.installBootLoader = lib.mkForce (
      pkgs.writeShellScript "install-systemd-boot-readonly.sh" ''
        #!${pkgs.runtimeShell}
        set -euo pipefail

        echo "Remounting /boot read-write for bootloader installation..."
        ${pkgs.util-linux}/bin/mount -o remount,rw /boot || true

        ${systemdBootBuilder}/bin/systemd-boot "$@"
        ${cfg.extraInstallCommands}

        echo "Syncing and remounting /boot read-only..."
        ${pkgs.toybox}/bin/sync
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
