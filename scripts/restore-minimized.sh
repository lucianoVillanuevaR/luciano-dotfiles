#!/usr/bin/env bash
set -euo pipefail

[[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] || exit 0
command -v hyprctl >/dev/null 2>&1 || exit 0
command -v rofi >/dev/null 2>&1 || exit 0

lua_quote() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  printf '"%s"' "$value"
}

notify_empty() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "No hay ventanas minimizadas"
  fi
}

active_workspace="$(hyprctl activeworkspace -j 2>/dev/null || true)"
[[ -n "$active_workspace" ]] || exit 0

if command -v jq >/dev/null 2>&1; then
  current_workspace="$(jq -r '.name // .id // empty' <<<"$active_workspace")"
else
  command -v python3 >/dev/null 2>&1 || exit 0
  current_workspace="$(
    ACTIVE_WORKSPACE="$active_workspace" python3 - <<'PY'
import json
import os

try:
    workspace = json.loads(os.environ["ACTIVE_WORKSPACE"])
    print(workspace.get("name") or workspace.get("id") or "")
except Exception:
    pass
PY
  )"
fi

[[ -n "$current_workspace" ]] || exit 0

clients="$(hyprctl clients -j 2>/dev/null || true)"
[[ -n "$clients" ]] || exit 0

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

if command -v jq >/dev/null 2>&1; then
  jq -r '
    .[]
    | select(.workspace.name == "special:minimized")
    | [
        .address,
        (((.class // "unknown") | gsub("[\t\r\n]"; " ")) + " — " + ((.title // "Untitled") | gsub("[\t\r\n]"; " ")))
      ]
    | @tsv
  ' <<<"$clients" >"$tmp_file"
else
  command -v python3 >/dev/null 2>&1 || exit 0
  CLIENTS="$clients" python3 - <<'PY' >"$tmp_file"
import json
import os

def clean(value):
    return str(value or "").replace("\t", " ").replace("\r", " ").replace("\n", " ")

try:
    clients = json.loads(os.environ["CLIENTS"])
except Exception:
    clients = []

for client in clients:
    if client.get("workspace", {}).get("name") != "special:minimized":
        continue

    address = clean(client.get("address"))
    class_name = clean(client.get("class") or "unknown")
    title = clean(client.get("title") or "Untitled")
    if address:
        print(f"{address}\t{class_name} — {title}")
PY
fi

if [[ ! -s "$tmp_file" ]]; then
  notify_empty
  exit 0
fi

selection="$(
  cut -f2- "$tmp_file" | rofi -dmenu -i -p "Minimized" -format i || true
)"

[[ -n "$selection" ]] || exit 0
[[ "$selection" =~ ^[0-9]+$ ]] || exit 0

line_number=$((selection + 1))
address="$(sed -n "${line_number}p" "$tmp_file" | cut -f1)"
[[ -n "$address" ]] || exit 0

workspace_ref="$(lua_quote "$current_workspace")"
window_ref="$(lua_quote "address:$address")"

hyprctl dispatch "hl.dsp.window.move({ workspace = $workspace_ref, window = $window_ref, follow = false })" >/dev/null
hyprctl dispatch "hl.dsp.focus({ window = $window_ref })" >/dev/null
