# Local Equibop wrapper fixes (kept out of nixpkgs per PR feedback)
#
# - Equibop mutates ~/.config/equibop/settings/settings.json at runtime. If that
#   file is a Home Manager symlink into /nix/store, writes fail with EROFS.
# - Chromium's speech-dispatcher integration can crash on startup for some
#   users; keep it opt-in via $NIXOS_SPEECH instead of forcing it on.
_final: prev:
let
  inherit (prev) lib;
in
{
  equibop = prev.equibop.overrideAttrs (oldAttrs: {
    postFixup =
      (oldAttrs.postFixup or "")
      + ''
        # Ensure runtime tools are available and fix EROFS settings.json writes.
        wrapProgram "$out/bin/equibop" \
          --unset NIXOS_SPEECH \
          --prefix PATH : ${lib.makeBinPath [ prev.coreutils prev.speechd ]} \
          --run '
            # Hard-disable Chromium speech APIs by default to avoid Electron
            # speech-dispatcher crashes. Opt-in by setting EQUIBOP_SPEECH=1.
            #
            # Note: we use a custom env var (not NIXOS_SPEECH) because some
            # desktops export NIXOS_SPEECH globally.
            case "''${EQUIBOP_SPEECH:-}" in
              1|true|TRUE|True|yes|YES|on|ON)
                export NIXOS_SPEECH=True
                set -- --enable-speech-dispatcher "$@"
                ;;
              *)
                unset NIXOS_SPEECH
                set -- --disable-speech-api --disable-speech-synthesis-api "$@"
                ;;
            esac

            cfg_home="''${XDG_CONFIG_HOME:-$HOME/.config}"
            cfg_file="$cfg_home/equibop/settings/settings.json"

            # Home Manager (and similar tooling) may symlink config files into
            # the Nix store, which is read-only. Equibop expects to mutate this
            # file at runtime, so replace a read-only store symlink with a
            # writable copy.
            if [[ -L "$cfg_file" && ! -w "$cfg_file" ]]; then
              target="$(readlink -f "$cfg_file" 2>/dev/null || true)"
              if [[ "$target" == /nix/store/* ]]; then
                cfg_dir="''${cfg_file%/*}"
                mkdir -p "$cfg_dir"
                tmp="$(mktemp -p "$cfg_dir" settings.json.XXXXXX)"
                if cp -L "$cfg_file" "$tmp" 2>/dev/null; then
                  rm -f "$cfg_file"
                  mv -f "$tmp" "$cfg_file"
                else
                  rm -f "$tmp"
                  rm -f "$cfg_file"
                fi
              fi
            fi
          '

        # Electron's speech-dispatcher integration currently causes SIGTRAP
        # crashes for some users. Keep it opt-in by removing the default flag.
        #
        # (Users can still pass `--enable-speech-dispatcher` manually.)
        if [ -f "$out/bin/.equibop-wrapped" ]; then
          substituteInPlace "$out/bin/.equibop-wrapped" \
            --replace-quiet "--enable-speech-dispatcher" ""
        else
          substituteInPlace "$out/bin/equibop" \
            --replace-quiet "--enable-speech-dispatcher" ""
        fi
      '';
  });
}
