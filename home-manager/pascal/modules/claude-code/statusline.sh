# shellcheck shell=bash
# Status line: model | effort | context used | 5h usage | 7d usage
export LC_NUMERIC=C
input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name // "?"')
ctx=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

effort=$(echo "$input" | jq -r '.effort.level // empty')

RST=$'\e[0m'
MAGENTA=$'\e[35m'
DIM=$'\e[2m'
CYAN=$'\e[36m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
RED=$'\e[31m'

# pct_color N -> color escape by threshold (green <50, yellow 50-79, red >=80)
pct_color() {
  if [ "$1" -ge 80 ]; then printf '%s' "$RED"
  elif [ "$1" -ge 50 ]; then printf '%s' "$YELLOW"
  else printf '%s' "$GREEN"; fi
}

# seg LABEL VALUE -> colored "LABEL: N%"
seg() {
  local n
  n=$(printf '%.0f' "$2")
  printf '%s%s:%s %s%s%%%s' "$DIM" "$1" "$RST" "$(pct_color "$n")" "$n" "$RST"
}

SEP=" ${DIM}|${RST} "
out="${CYAN}${model}${RST}"
[ -n "$effort" ] && out="$out$SEP${DIM}effort:${RST} ${MAGENTA}${effort}${RST}"
if [ -n "$ctx" ]; then
  out="$out$SEP$(seg ctx "$ctx")"
else
  out="$out$SEP${DIM}ctx: -${RST}"
fi
[ -n "$five" ] && out="$out$SEP$(seg 5h "$five")"
[ -n "$week" ] && out="$out$SEP$(seg 7d "$week")"
printf '%s\n' "$out"
