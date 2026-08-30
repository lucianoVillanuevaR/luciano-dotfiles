#!/usr/bin/env bash
set -Eeuo pipefail

if ! command -v cliphist >/dev/null 2>&1; then
  notify-send "Clipboard" "cliphist is not installed" 2>/dev/null || true
  exit 1
fi

if ! command -v rofi >/dev/null 2>&1; then
  notify-send "Clipboard" "rofi is not installed" 2>/dev/null || true
  exit 1
fi

if ! command -v wl-copy >/dev/null 2>&1; then
  notify-send "Clipboard" "wl-clipboard is not installed" 2>/dev/null || true
  exit 1
fi

selection="$(cliphist list | rofi -dmenu -i -p Clipboard)"
[[ -n "$selection" ]] || exit 0

printf '%s' "$selection" | cliphist decode | wl-copy
