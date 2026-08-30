#!/usr/bin/env bash

DISTRO_ID=""
DISTRO_ID_LIKE=""
DISTRO_PRETTY_NAME=""
IS_ARCH_LIKE=0
IS_CACHYOS=0
PACMAN_BIN=""
AUR_HELPER=""

detect_distro() {
  [[ -r /etc/os-release ]] || die "/etc/os-release not found"
  # shellcheck disable=SC1091
  source /etc/os-release
  DISTRO_ID="${ID:-unknown}"
  DISTRO_ID_LIKE="${ID_LIKE:-}"
  DISTRO_PRETTY_NAME="${PRETTY_NAME:-$DISTRO_ID}"

  if [[ "$DISTRO_ID" == "cachyos" ]]; then
    IS_CACHYOS=1
    IS_ARCH_LIKE=1
  elif [[ "$DISTRO_ID" == "arch" || "$DISTRO_ID_LIKE" == *arch* ]]; then
    IS_ARCH_LIKE=1
  fi

  log_ok "Detected system: $DISTRO_PRETTY_NAME"
}

detect_package_tools() {
  if command_exists pacman; then
    PACMAN_BIN="$(command -v pacman)"
    log_ok "pacman detected: $PACMAN_BIN"
  else
    log_warn "pacman not detected. Package installation will be unavailable."
  fi

  if command_exists paru; then
    AUR_HELPER="$(command -v paru)"
    log_ok "AUR helper detected: paru"
  elif command_exists yay; then
    AUR_HELPER="$(command -v yay)"
    log_ok "AUR helper detected: yay"
  else
    log_warn "No AUR helper detected. AUR packages will be skipped."
  fi
}
