#!/usr/bin/env bash
set -euo pipefail

[[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] || exit 0

for command in hyprctl kitty jq; do
  command -v "$command" >/dev/null 2>&1 || exit 0
done

lua_quote() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  printf '"%s"' "$value"
}

quick_terminal_address() {
  hyprctl clients -j 2>/dev/null |
    jq -r '.[] | select(.class == "quick-terminal") | .address' |
    head -n 1
}

address="$(quick_terminal_address || true)"

if [[ -z "$address" ]]; then
  kitty --class quick-terminal --title "Quick Terminal" >/dev/null 2>&1 &

  for _ in {1..30}; do
    sleep 0.1
    address="$(quick_terminal_address || true)"
    [[ -n "$address" ]] && break
  done
fi

[[ -n "$address" && "$address" != "0x0" ]] || exit 0

window_ref="$(lua_quote "address:$address")"

hyprctl dispatch "hl.dsp.window.move({ workspace = \"special:quickterm\", window = $window_ref, follow = false })" >/dev/null
hyprctl dispatch 'hl.dsp.workspace.toggle_special("quickterm")' >/dev/null
