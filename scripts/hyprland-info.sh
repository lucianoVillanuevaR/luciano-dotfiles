#!/usr/bin/env bash
set -Eeuo pipefail

section() {
  printf '\n== %s ==\n' "$1"
}

run_optional() {
  local label="$1"
  shift
  section "$label"
  "$@" 2>/dev/null || true
}

section "Hyprland"
Hyprland --version 2>/dev/null || hyprctl version 2>/dev/null || true
pacman -Q hyprland 2>/dev/null || true

section "Session"
printf 'XDG_SESSION_TYPE=%s\n' "${XDG_SESSION_TYPE:-}"
printf 'XDG_CURRENT_DESKTOP=%s\n' "${XDG_CURRENT_DESKTOP:-}"
printf 'XDG_SESSION_DESKTOP=%s\n' "${XDG_SESSION_DESKTOP:-}"

run_optional "GPU PCI devices" lspci -d ::03xx
run_optional "DRI by-path" ls -l /dev/dri/by-path
run_optional "NVIDIA" nvidia-smi

section "Wayland sessions"
find /usr/share/wayland-sessions -maxdepth 1 -type f -printf '%f\n' 2>/dev/null | sort || true

section "Packages"
pacman -Q \
  waybar \
  rofi rofi-wayland \
  wl-clipboard cliphist \
  grim slurp \
  hyprlock wlogout \
  xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-kde \
  uwsm 2>/dev/null || true

section "Tools"
for cmd in waybar rofi cliphist wl-copy grim slurp hyprlock wlogout uwsm; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '%-12s %s\n' "$cmd" "$(command -v "$cmd")"
  else
    printf '%-12s missing\n' "$cmd"
  fi
done

if [[ "${XDG_CURRENT_DESKTOP:-}" == *Hyprland* ]] && command -v hyprctl >/dev/null 2>&1; then
  run_optional "Hyprland monitors" hyprctl monitors all
else
  section "Hyprland monitors"
  printf 'Not running inside Hyprland; skipping hyprctl monitors all.\n'
fi
