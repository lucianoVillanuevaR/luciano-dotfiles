#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$HOME/.dotfiles"
LIBRARY_DIR="$REPO_DIR/wallpapers/library"
CURRENT_WALLPAPER="$REPO_DIR/wallpapers/current.jpg"
ROFI_THEME="$REPO_DIR/config/rofi/wallpaper-selector.rasi"
ROFI_PID="${XDG_RUNTIME_DIR:-/tmp}/luciano-wallpaper-menu.pid"

cleanup() {
  [[ -n "${TMP_WALLPAPER:-}" ]] && rm -f -- "$TMP_WALLPAPER"
}

die_missing_tool() {
  rofi -e "$1"
  exit 0
}

find_wallpapers() {
  find "$LIBRARY_DIR" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
    -printf '%f\t%p\n' |
    sort -f
}

show_empty_message() {
  printf 'Agrega imagenes a ~/.dotfiles/wallpapers/library/\n' |
    rofi -dmenu \
      -p "Wallpapers" \
      -mesg "No hay wallpapers" \
      -no-custom \
      -theme "$ROFI_THEME" \
      -window-title "luciano-wallpaper-menu" \
      -pid "$ROFI_PID" >/dev/null || true
}

select_wallpaper() {
  local -n labels_ref="$1"
  local -n paths_ref="$2"
  local index entry

  for index in "${!labels_ref[@]}"; do
    entry="${labels_ref[$index]}"
    printf '%s\0icon\x1f%s\x1finfo\x1f%s\n' "$entry" "${paths_ref[$index]}" "${paths_ref[$index]}"
  done |
    rofi -dmenu \
      -i \
      -no-custom \
      -show-icons \
      -format i \
      -p "Wallpapers" \
      -theme "$ROFI_THEME" \
      -window-title "luciano-wallpaper-menu" \
      -pid "$ROFI_PID" \
      -replace
}

apply_wallpaper() {
  local source="$1"

  TMP_WALLPAPER="$(mktemp --tmpdir="$(dirname -- "$CURRENT_WALLPAPER")" .current.jpg.XXXXXX)"
  cp -- "$source" "$TMP_WALLPAPER"
  mv -- "$TMP_WALLPAPER" "$CURRENT_WALLPAPER"
  TMP_WALLPAPER=""

  if pgrep -u "${USER:-$(id -un)}" -x hyprpaper >/dev/null 2>&1; then
    if hyprctl hyprpaper wallpaper ",$CURRENT_WALLPAPER,cover" >/dev/null 2>&1; then
      return 0
    fi

    pkill -x hyprpaper 2>/dev/null || true
  fi

  "$REPO_DIR/scripts/start-wallpaper.sh"
}

main() {
  trap cleanup EXIT

  command -v rofi >/dev/null 2>&1 || exit 0
  command -v hyprpaper >/dev/null 2>&1 || die_missing_tool "hyprpaper no esta instalado"
  command -v hyprctl >/dev/null 2>&1 || die_missing_tool "hyprctl no esta instalado"

  mkdir -p -- "$LIBRARY_DIR"

  local labels=()
  local paths=()
  local name path selected

  while IFS=$'\t' read -r name path; do
    labels+=("$name")
    paths+=("$path")
  done < <(find_wallpapers)

  if [[ "${#paths[@]}" -eq 0 ]]; then
    show_empty_message
    exit 0
  fi

  selected="$(select_wallpaper labels paths || true)"
  [[ -n "$selected" ]] || exit 0
  [[ "$selected" =~ ^[0-9]+$ ]] || exit 0
  [[ "$selected" -ge 0 && "$selected" -lt "${#paths[@]}" ]] || exit 0

  apply_wallpaper "${paths[$selected]}"
}

main "$@"
