#!/usr/bin/env bash
set -Eeuo pipefail

for cmd in grim wl-copy; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    notify-send "Screenshot" "$cmd is not installed" 2>/dev/null || true
    exit 1
  fi
done

directory="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$directory"

file="$directory/screenshot-$(date +%Y%m%d-%H%M%S).png"
grim "$file"
wl-copy --type image/png < "$file"
notify-send "Screenshot saved" "$file" 2>/dev/null || true
