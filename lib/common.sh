#!/usr/bin/env bash

log_info() { printf '[ INFO ] %s\n' "$*"; }
log_ok() { printf '[ OK ] %s\n' "$*"; }
log_warn() { printf '[ WARN ] %s\n' "$*" >&2; }
log_fail() { printf '[ FAIL ] %s\n' "$*" >&2; }
die() { log_fail "$*"; exit 1; }

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

run_cmd() {
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    printf '[ DRY ]'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

require_not_root() {
  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    die "Do not run this installer as root. Run it as your normal user."
  fi
}
