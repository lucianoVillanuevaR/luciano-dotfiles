#!/usr/bin/env bash

BACKUP_ROOT="${HOME}/.local/share/luciano-dotfiles/backups"
BACKUP_SESSION=""
BACKUP_LAST_PATH=""

ensure_backup_session() {
  if [[ -n "$BACKUP_SESSION" ]]; then
    return 0
  fi

  local stamp
  stamp="$(date '+%Y-%m-%d_%H-%M-%S')"
  BACKUP_SESSION="$BACKUP_ROOT/$stamp"
  mkdir -p -- "$BACKUP_SESSION"
}

unique_backup_dest() {
  local target="$1"
  local rel="${target#"$HOME"/}"
  local dest="$BACKUP_SESSION/$rel"
  local candidate="$dest"
  local counter=1

  while [[ -e "$candidate" || -L "$candidate" ]]; do
    candidate="${dest}.backup-${counter}"
    counter=$((counter + 1))
  done

  printf '%s\n' "$candidate"
}

backup_path() {
  local target="$1"
  BACKUP_LAST_PATH=""
  [[ -e "$target" || -L "$target" ]] || return 0

  ensure_backup_session

  local dest
  dest="$(unique_backup_dest "$target")"
  mkdir -p -- "$(dirname -- "$dest")"
  mv -- "$target" "$dest"
  BACKUP_LAST_PATH="$dest"
  log_ok "Backed up $target to $dest"
}

preview_install_config_dir() {
  local target="$1"
  local source="$2"

  if [[ -L "$target" ]]; then
    local current
    current="$(readlink -- "$target")"
    if [[ "$current" == "$source" ]]; then
      log_ok "Already linked: $target -> $source"
      return 0
    fi
    log_dry "back up symlink $target -> $current"
  elif [[ -e "$target" ]]; then
    if [[ -d "$target" ]]; then
      log_dry "back up directory $target"
    else
      log_dry "back up file $target"
    fi
  fi

  log_dry "create parent directory $(dirname -- "$target")"
  log_dry "link $target -> $source"
}

install_config_dir() {
  local name="$1"
  local target="$2"
  local source="$SCRIPT_DIR/config/$name"

  [[ -d "$source" ]] || die "Missing config source: $source"

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    preview_install_config_dir "$target" "$source"
    return 0
  fi

  if [[ -L "$target" ]]; then
    local current
    current="$(readlink -- "$target")"
    if [[ "$current" == "$source" ]]; then
      log_ok "Already linked: $target -> $source"
      return 0
    fi
  fi

  local backup=""
  if [[ -e "$target" || -L "$target" ]]; then
    backup_path "$target"
    backup="$BACKUP_LAST_PATH"
  fi

  mkdir -p -- "$(dirname -- "$target")"
  if ln -s -- "$source" "$target"; then
    log_ok "Linked $target -> $source"
    return 0
  fi

  log_fail "Failed to link $target -> $source"
  if [[ -n "$backup" ]]; then
    log_warn "Restoring original configuration from $backup"
    if mv -- "$backup" "$target"; then
      log_ok "Restored $target"
    else
      log_fail "Rollback failed. Backup remains at $backup"
    fi
  fi
  return 1
}
