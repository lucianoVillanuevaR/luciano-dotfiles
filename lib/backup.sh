#!/usr/bin/env bash

BACKUP_ROOT="${HOME}/.local/share/luciano-dotfiles/backups"
BACKUP_SESSION=""

ensure_backup_session() {
  if [[ -n "$BACKUP_SESSION" ]]; then
    return 0
  fi

  local stamp
  stamp="$(date '+%Y-%m-%d_%H-%M-%S')"
  BACKUP_SESSION="$BACKUP_ROOT/$stamp"
  run_cmd mkdir -p "$BACKUP_SESSION"
}

backup_path() {
  local target="$1"
  [[ -e "$target" || -L "$target" ]] || return 0

  ensure_backup_session

  local rel="${target#"$HOME"/}"
  local dest="$BACKUP_SESSION/$rel"
  run_cmd mkdir -p "$(dirname -- "$dest")"
  run_cmd mv -- "$target" "$dest"
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log_info "Would back up $target to $dest"
  else
    log_ok "Backed up $target to $dest"
  fi
}

install_config_dir() {
  local name="$1"
  local target="$2"
  local source="$SCRIPT_DIR/config/$name"

  [[ -d "$source" ]] || die "Missing config source: $source"

  if [[ -L "$target" ]]; then
    local current
    current="$(readlink -- "$target")"
    if [[ "$current" == "$source" ]]; then
      log_ok "$target already linked"
      return 0
    fi
  fi

  backup_path "$target"
  run_cmd mkdir -p "$(dirname -- "$target")"
  run_cmd ln -sfn -- "$source" "$target"
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log_info "Would link $target -> $source"
  else
    log_ok "Linked $target -> $source"
  fi
}
