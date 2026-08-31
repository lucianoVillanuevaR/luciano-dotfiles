#!/usr/bin/env bash
set -Eeuo pipefail

focused_monitor() {
  hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name' | head -n 1
}

run_swayosd() {
  local monitor
  monitor="$(focused_monitor)"

  if [[ -n "$monitor" ]]; then
    swayosd-client --monitor "$monitor" "$@"
  else
    swayosd-client "$@"
  fi
}

main() {
  local action="${1:-}"

  case "$action" in
    volume-up)
      run_swayosd --output-volume +5 --max-volume 100
      ;;
    volume-down)
      run_swayosd --output-volume -5 --max-volume 100
      ;;
    volume-mute)
      run_swayosd --output-volume mute-toggle --max-volume 100
      ;;
    brightness-up)
      run_swayosd --brightness +5 --device "amdgpu_bl*"
      ;;
    brightness-down)
      run_swayosd --brightness -5 --device "amdgpu_bl*"
      ;;
    *)
      printf 'Usage: %s {volume-up|volume-down|volume-mute|brightness-up|brightness-down}\n' "${0##*/}" >&2
      exit 2
      ;;
  esac
}

main "$@"
