#!/usr/bin/env bash
set -Eeuo pipefail

for cmd in grim slurp wl-copy; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    notify-send "Screenshot" "$cmd is not installed" 2>/dev/null || true
    exit 1
  fi
done

directory="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$directory"

geometry="$(slurp)"
[[ -n "$geometry" ]] || exit 0

file="$directory/screenshot-area-$(date +%Y%m%d-%H%M%S).png"
grim -g "$geometry" "$file"
wl-copy --type image/png < "$file"
notify-send "Area screenshot saved" "$file" 2>/dev/null || true
