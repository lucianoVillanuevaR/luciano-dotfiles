#!/usr/bin/env bash
set -Eeuo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/luciano-dotfiles"
LOG_FILE="$STATE_DIR/session-actions.log"
LOCK_CONFIG="$HOME/.dotfiles/config/hyprlock/hyprlock.conf"
DRY_RUN="${SESSION_ACTION_DRY_RUN:-0}"

log_error() {
  mkdir -p "$STATE_DIR"
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S %z')" "$*" >>"$LOG_FILE"
}

notify_error() {
  local message="$1"

  log_error "ERROR: $message"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Sesion" "$message"
  fi
}

require_command() {
  local command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    notify_error "$command_name no disponible"
    exit 1
  fi
}

require_lock() {
  require_command hyprlock

  if [[ ! -f "$LOCK_CONFIG" ]]; then
    notify_error "Config de hyprlock no existe"
    exit 1
  fi
}

exec_or_print() {
  if [[ "$DRY_RUN" == 1 ]]; then
    printf '%s\n' "$*"
    return 0
  fi

  exec "$@"
}

hypr_instance_valid() {
  local signature="$1"

  [[ -n "$signature" ]] || return 1
  require_command jq

  hyprctl instances -j 2>/dev/null |
    jq -e --arg instance "$signature" --arg wl_socket "${WAYLAND_DISPLAY:-}" '
      .[] | select(.instance == $instance and ($wl_socket == "" or .wl_socket == $wl_socket))
    ' >/dev/null
}

resolve_hypr_instance() {
  require_command hyprctl
  require_command jq

  if hypr_instance_valid "${HYPRLAND_INSTANCE_SIGNATURE:-}"; then
    printf '%s\n' "$HYPRLAND_INSTANCE_SIGNATURE"
    return 0
  fi

  hyprctl instances -j 2>/dev/null |
    jq -er --arg wl_socket "${WAYLAND_DISPLAY:-}" '
      if $wl_socket != "" then
        (.[] | select(.wl_socket == $wl_socket) | .instance)
      else
        (if length == 1 then .[0].instance else empty end)
      end
    ' | head -n 1
}

valid_logind_session() {
  local session_id="$1"
  local current_uid

  [[ -n "$session_id" ]] || return 1
  current_uid="$(id -u)"

  loginctl show-session "$session_id" \
    -p User -p Type -p Remote -p Active -p State -p Class --value 2>/dev/null |
    awk -v uid="$current_uid" '
      NR == 1 { user = $0 }
      NR == 2 { type = $0 }
      NR == 3 { remote = $0 }
      NR == 4 { active = $0 }
      NR == 5 { state = $0 }
      NR == 6 { class = $0 }
      END {
        exit !(user == uid && type == "wayland" && remote == "no" &&
          (active == "yes" || state == "active") && (class == "" || class == "user"))
      }
    '
}

resolve_logind_session() {
  local session_id

  require_command loginctl

  if valid_logind_session "${XDG_SESSION_ID:-}"; then
    printf '%s\n' "$XDG_SESSION_ID"
    return 0
  fi

  session_id="$(loginctl show-user "$USER" -p Display --value 2>/dev/null || true)"
  if valid_logind_session "$session_id"; then
    printf '%s\n' "$session_id"
    return 0
  fi

  loginctl show-user "$USER" -p Sessions --value 2>/dev/null |
    tr ' ' '\n' |
    while IFS= read -r session_id; do
      if valid_logind_session "$session_id"; then
        printf '%s\n' "$session_id"
        return 0
      fi
    done
}

lock_session() {
  require_lock
  exec_or_print hyprlock --config "$LOCK_CONFIG"
}

logout_session() {
  local instance session_id

  if instance="$(resolve_hypr_instance)"; then
    export HYPRLAND_INSTANCE_SIGNATURE="$instance"
    if [[ "$DRY_RUN" == 1 ]]; then
      printf 'HYPRLAND_INSTANCE_SIGNATURE=%s hyprctl dispatch exit\n' "$instance"
      return 0
    fi

    if hyprctl dispatch exit; then
      exit 0
    fi

    log_error "ERROR: hyprctl dispatch exit fallo con instancia $instance"
  else
    log_error "ERROR: no se pudo resolver instancia Hyprland para logout"
  fi

  if session_id="$(resolve_logind_session)"; then
    log_error "fallback: loginctl terminate-session $session_id"
    exec_or_print loginctl terminate-session "$session_id"
    return 0
  fi

  notify_error "No se pudo resolver sesion grafica para cerrar"
  exit 1
}

suspend_session() {
  local _attempt

  require_command systemctl
  require_lock

  if [[ "$DRY_RUN" == 1 ]]; then
    printf 'hyprlock --config %s &\n' "$LOCK_CONFIG"
    printf 'systemctl suspend\n'
    return 0
  fi

  hyprlock --config "$LOCK_CONFIG" >/dev/null 2>&1 &

  for _attempt in 1 2 3 4 5 6 7; do
    if pgrep -u "${USER:-$(id -un)}" -x hyprlock >/dev/null 2>&1; then
      exec systemctl suspend
    fi
    sleep 0.05
  done

  notify_error "hyprlock no inicio; no se suspende"
  exit 1
}

case "${1:-}" in
  lock) lock_session ;;
  logout) logout_session ;;
  suspend) suspend_session ;;
  reboot) exec_or_print systemctl reboot ;;
  poweroff) exec_or_print systemctl poweroff ;;
  *) exit 2 ;;
esac
