# Claude Code status line: model | effort | context used | 5h usage | 7d usage
# (colors and thresholds are in statusline.sh).
#
# programs.claude-code.settings would turn ~/.claude/settings.json into a
# read-only store link, but Claude Code saves its own state there (model,
# effort, plugins, tui), so only the statusLine key and the env vars below are
# merged in on every switch and the rest of the file is left alone.
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

  # No telemetry, error reports, feature-flag fetches or other nonessential
  # traffic. Merged into .env, so other env vars set there are kept.
  env = {
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
    DISABLE_TELEMETRY = "1";
    DISABLE_ERROR_REPORTING = "1";
    DISABLE_BUG_COMMAND = "1";
    DISABLE_GROWTHBOOK = "1";
    DO_NOT_TRACK = "1";
    CLAUDE_CODE_ENABLE_TELEMETRY = "0";
  };

  jq = lib.getExe pkgs.jq;
in
{
  home.activation.claudeStatusLine = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    settings="$HOME/.claude/settings.json"
    tmp=$(mktemp)
    if { [ -s "$settings" ] && cat "$settings" || echo '{}'; } \
        | ${jq} \
            --argjson s ${lib.escapeShellArg (builtins.toJSON statusLine)} \
            --argjson e ${lib.escapeShellArg (builtins.toJSON env)} \
            '.statusLine = $s | .env = ((.env // {}) + $e)' > "$tmp"; then
      if ! cmp -s "$tmp" "$settings"; then
        run mkdir -p "$HOME/.claude"
        run install -m 600 "$tmp" "$settings"
      fi
    else
      warnEcho "claude-code: $settings is not valid JSON, statusLine/env not set"
    fi
    rm -f "$tmp"
  '';
}
