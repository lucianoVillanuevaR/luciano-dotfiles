#!/usr/bin/env bash
set -Eeuo pipefail

if command -v pacman >/dev/null 2>&1; then
  printf '[ INFO ] Updating Arch/CachyOS packages with pacman\n'
  sudo pacman -Syu
else
  printf '[ FAIL ] pacman not found. No updater implemented for this system yet.\n' >&2
  exit 1
fi
