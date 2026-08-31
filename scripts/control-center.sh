#!/usr/bin/env bash
set -euo pipefail

ROFI_THEME="$HOME/.dotfiles/config/rofi/luciano-dark.rasi"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$1"
  fi
}

wifi_label() {
  if ! command -v nmcli >/dev/null 2>&1; then
    printf 'Wi-Fi: No disponible\n'
    return
  fi

  case "$(nmcli radio wifi 2>/dev/null || true)" in
    enabled) printf 'Wi-Fi: Activado\n' ;;
    disabled) printf 'Wi-Fi: Desactivado\n' ;;
    *) printf 'Wi-Fi: No disponible\n' ;;
  esac
}

bluetooth_label() {
  if ! command -v bluetoothctl >/dev/null 2>&1; then
    printf 'Bluetooth: No disponible\n'
    return
  fi

  state="$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/ {print $2; exit}')"
  case "$state" in
    yes) printf 'Bluetooth: Activado\n' ;;
    no) printf 'Bluetooth: Desactivado\n' ;;
    *) printf 'Bluetooth: No disponible\n' ;;
  esac
}

dnd_label() {
  if ! command -v swaync-client >/dev/null 2>&1; then
    printf 'No molestar: No disponible\n'
    return
  fi

  case "$(swaync-client -D 2>/dev/null || true)" in
    true) printf 'No molestar: Activado\n' ;;
    false) printf 'No molestar: Desactivado\n' ;;
    *) printf 'No molestar\n' ;;
  esac
}

toggle_wifi() {
  command -v nmcli >/dev/null 2>&1 || {
    notify "Wi-Fi: No disponible"
    return
  }

  case "$(nmcli radio wifi 2>/dev/null || true)" in
    enabled)
      nmcli radio wifi off && notify "Wi-Fi: Desactivado"
      ;;
    disabled)
      nmcli radio wifi on && notify "Wi-Fi: Activado"
      ;;
    *)
      notify "Wi-Fi: No disponible"
      ;;
  esac
}

toggle_bluetooth() {
  command -v bluetoothctl >/dev/null 2>&1 || {
    notify "Bluetooth: No disponible"
    return
  }

  state="$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/ {print $2; exit}')"
  case "$state" in
    yes)
      bluetoothctl power off >/dev/null && notify "Bluetooth: Desactivado"
      ;;
    no)
      bluetoothctl power on >/dev/null && notify "Bluetooth: Activado"
      ;;
    *)
      notify "Bluetooth: No disponible"
      ;;
  esac
}

toggle_dnd() {
  command -v swaync-client >/dev/null 2>&1 || {
    notify "No molestar: No disponible"
    return
  }

  new_state="$(swaync-client -d 2>/dev/null || true)"
  case "$new_state" in
    true) notify "No molestar: Activado" ;;
    false) notify "No molestar: Desactivado" ;;
  esac
}

open_audio() {
  command -v pavucontrol >/dev/null 2>&1 || {
    notify "Audio: pavucontrol no disponible"
    return
  }

  if command -v hyprctl >/dev/null 2>&1 &&
    command -v jq >/dev/null 2>&1 &&
    hyprctl clients -j 2>/dev/null | jq -e '.[] | select(.class == "org.pulseaudio.pavucontrol")' >/dev/null 2>&1; then
    return
  fi

  pavucontrol >/dev/null 2>&1 &
}

command -v rofi >/dev/null 2>&1 || exit 0

wifi="$(wifi_label)"
bluetooth="$(bluetooth_label)"
dnd="$(dnd_label)"

selection="$(
  printf 'Modo de energía\nAudio\n%s\n%s\n%s\nBloquear\nSesión / Apagar\n' "$wifi" "$bluetooth" "$dnd" |
    rofi -dmenu -i -p "Centro" -theme "$ROFI_THEME" || true
)"

case "$selection" in
  "Modo de energía") "$HOME/.dotfiles/scripts/power-profile-menu.sh" ;;
  Audio) open_audio ;;
  Wi-Fi:*) toggle_wifi ;;
  Bluetooth:*) toggle_bluetooth ;;
  "No molestar"*) toggle_dnd ;;
  Bloquear) "$HOME/.dotfiles/scripts/session-action.sh" lock ;;
  "Sesión / Apagar")
    pgrep -x wlogout >/dev/null 2>&1 ||
      PATH="$HOME/.dotfiles/scripts:$PATH" wlogout --buttons-per-row 5 --column-spacing 12 --row-spacing 12 --margin-left 360 --margin-right 360 --margin-top 420 --margin-bottom 420
    ;;
  "") exit 0 ;;
esac
