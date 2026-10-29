# Claude Code status line: model | effort | context used | 5h usage | 7d usage
# (colors and thresholds are in statusline.sh).
#
# programs.claude-code.settings would turn ~/.claude/settings.json into a
# read-only store link, but Claude Code saves its own state there (model,
# effort, plugins, tui), so only the statusLine key is merged in on every
# switch and the rest of the file is left alone.
{ lib, pkgs, ... }:
let
  statusline = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.jq
    ];
    text = builtins.readFile ./statusline.sh;
  };

  statusLine = {
    type = "command";
    command = lib.getExe statusline;
  };

  jq = lib.getExe pkgs.jq;
in
{
  home.activation.claudeStatusLine = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    settings="$HOME/.claude/settings.json"
    tmp=$(mktemp)
    if { [ -s "$settings" ] && cat "$settings" || echo '{}'; } \
        | ${jq} --argjson s ${lib.escapeShellArg (builtins.toJSON statusLine)} '.statusLine = $s' > "$tmp"; then
      if ! cmp -s "$tmp" "$settings"; then
        run mkdir -p "$HOME/.claude"
        run install -m 600 "$tmp" "$settings"
      fi
    else
      warnEcho "claude-code: $settings is not valid JSON, statusLine not set"
    fi
    rm -f "$tmp"
  '';
}
