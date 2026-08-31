#!/usr/bin/env bash
set -euo pipefail

[[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] || exit 0
command -v hyprctl >/dev/null 2>&1 || exit 0

lua_quote() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  printf '"%s"' "$value"
}

active_window="$(hyprctl activewindow -j 2>/dev/null || true)"
[[ -n "$active_window" ]] || exit 0

if command -v jq >/dev/null 2>&1; then
  address="$(jq -r '.address // empty' <<<"$active_window")"
else
  command -v python3 >/dev/null 2>&1 || exit 0
  address="$(
    ACTIVE_WINDOW="$active_window" python3 - <<'PY'
import json
import os

try:
    print(json.loads(os.environ["ACTIVE_WINDOW"]).get("address", ""))
except Exception:
    pass
PY
  )"
fi

[[ -n "$address" && "$address" != "0x0" ]] || exit 0

window_ref="$(lua_quote "address:$address")"

hyprctl dispatch "hl.dsp.window.move({ workspace = \"special:minimized\", window = $window_ref, follow = false })" >/dev/null
