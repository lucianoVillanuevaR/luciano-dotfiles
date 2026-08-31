#!/usr/bin/env bash
set -euo pipefail

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$1"
  fi
}

profile_label() {
  case "$1" in
    power-saver) printf 'Silencio\n' ;;
    balanced) printf 'Balanceado\n' ;;
    performance) printf 'Rendimiento\n' ;;
    *) printf '%s\n' "$1" ;;
  esac
}

if ! command -v powerprofilesctl >/dev/null 2>&1; then
  notify "Error: powerprofilesctl no esta disponible"
  exit 0
fi

if ! command -v rofi >/dev/null 2>&1; then
  notify "Error: rofi no esta disponible"
  exit 0
fi

current_profile="$(powerprofilesctl get 2>/dev/null || true)"
if [[ -z "$current_profile" ]]; then
  notify "Error: no se pudo obtener el modo de energia"
  exit 0
fi

current_label="$(profile_label "$current_profile")"

selection="$(
  printf 'Silencio\nBalanceado\nRendimiento\n' |
    rofi -dmenu -i -p "Modo actual: $current_label" || true
)"

case "$selection" in
  Silencio) target_profile="power-saver" ;;
  Balanceado) target_profile="balanced" ;;
  Rendimiento) target_profile="performance" ;;
  "") exit 0 ;;
  *) exit 0 ;;
esac

if ! powerprofilesctl set "$target_profile"; then
  notify "Error: no se pudo cambiar el modo de energia"
  exit 0
fi

confirmed_profile="$(powerprofilesctl get 2>/dev/null || true)"
if [[ "$confirmed_profile" != "$target_profile" ]]; then
  notify "Error: no se pudo confirmar el modo de energia"
  exit 0
fi

notify "Modo: $(profile_label "$confirmed_profile")"
