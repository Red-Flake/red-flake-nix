# Files that programs write to at runtime, so they can't be read-only store
# links. Each one is replaced by a fresh writable copy of its source at every
# login, and on switch when a source changes.
{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.custom.writableFiles;
in
{
  options.custom.writableFiles = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        source = lib.mkOption {
          type = lib.types.path;
          description = "File to copy.";
        };
        mode = lib.mkOption {
          type = lib.types.str;
          default = "0644";
          description = "Mode of the copy.";
        };
      };
    });
    default = { };
    description = "Writable copies to maintain, keyed by absolute target path.";
  };

  config = lib.mkIf (cfg != { }) {
    # A rule file of its own instead of systemd.user.tmpfiles.rules: sources
    # often come from another module's home.file, and reading those from that
    # option makes the evaluation recursive. NixOS enables the user
    # systemd-tmpfiles-setup.service, which applies this at login.
    # "r" removes the old copy, "C" copies the source. The owner must be
    # given: with "-" tmpfiles keeps the store file's root owner, which fails
    # with EPERM for the user instance and leaves a read-only copy behind.
    xdg.configFile."user-tmpfiles.d/writable-files.conf" = {
      text = lib.concatStrings (lib.mapAttrsToList
        (path: file: ''
          r ${path}
          C ${path} ${file.mode} ${config.home.username} users - ${file.source}
        '')
        cfg);
      onChange = ''
        run ${pkgs.systemd}/bin/systemd-tmpfiles --user --remove --create ''${DRY_RUN:+--dry-run}
      '';
    };
  };
}
