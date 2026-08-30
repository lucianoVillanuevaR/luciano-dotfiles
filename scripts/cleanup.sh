#!/usr/bin/env bash
set -Eeuo pipefail

targets=(
  "$HOME/.cache"
)

printf '[ INFO ] Cleanup preview:\n'
for target in "${targets[@]}"; do
  if [[ -d "$target" ]]; then
    du -sh -- "$target" 2>/dev/null | sed 's/^/[ INFO ] /'
  fi
done

read -r -p "Delete user cache contents? Type YES to continue: " answer
if [[ "$answer" != "YES" ]]; then
  printf '[ INFO ] Cleanup cancelled\n'
  exit 0
fi

find "$HOME/.cache" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
printf '[ OK ] User cache contents removed\n'
