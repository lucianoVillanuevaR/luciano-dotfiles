#!/usr/bin/env bash
set -Eeuo pipefail

WALLPAPER="$HOME/.dotfiles/wallpapers/current.jpg"

command -v hyprpaper >/dev/null 2>&1 || exit 0
[[ -f "$WALLPAPER" ]] || exit 0

if pgrep -u "${USER:-$(id -un)}" -x hyprpaper >/dev/null 2>&1; then
  exit 0
fi

hyprpaper >/dev/null 2>&1 &
