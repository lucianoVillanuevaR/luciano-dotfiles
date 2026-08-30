#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${HOME}/.local/share/luciano-dotfiles/backups/manual-$(date '+%Y-%m-%d_%H-%M-%S')"
managed=(
  "$HOME/.config/fish"
  "$HOME/.config/kitty"
  "$HOME/.config/fastfetch"
  "$HOME/.config/btop"
  "$HOME/.config/MangoHud"
)

mkdir -p "$ROOT"
for path in "${managed[@]}"; do
  if [[ -e "$path" || -L "$path" ]]; then
    rel="${path#"$HOME"/}"
    mkdir -p "$ROOT/$(dirname -- "$rel")"
    cp -a -- "$path" "$ROOT/$rel"
    printf '[ OK ] Backed up %s\n' "$path"
  fi
done
printf '[ INFO ] Backup directory: %s\n' "$ROOT"
