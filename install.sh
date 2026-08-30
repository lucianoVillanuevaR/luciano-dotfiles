#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
SCRIPT_DIR="$REPO_DIR"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
# shellcheck source=lib/distro.sh
source "$SCRIPT_DIR/lib/distro.sh"
# shellcheck source=lib/backup.sh
source "$SCRIPT_DIR/lib/backup.sh"
# shellcheck source=lib/packages.sh
source "$SCRIPT_DIR/lib/packages.sh"

DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage:
  ./install.sh [--dry-run] [common|cachyos|gaming|hyprland|hyprland-dotfiles|development|dotfiles|full]

Examples:
  ./install.sh --dry-run hyprland-dotfiles
  ./install.sh hyprland-dotfiles

Without a profile, an interactive menu is shown.
USAGE
}

install_dotfiles() {
  log_info "Installing managed dotfiles"
  install_config_dir "fish" "$HOME/.config/fish"
  install_config_dir "kitty" "$HOME/.config/kitty"
  install_config_dir "fastfetch" "$HOME/.config/fastfetch"
  install_config_dir "btop" "$HOME/.config/btop"
  install_config_dir "mangohud" "$HOME/.config/MangoHud"
}

hyprland_dotfiles_preflight() {
  local required=(Hyprland waybar rofi hyprlock wlogout wl-copy cliphist grim slurp)
  local missing=()
  local tool

  log_info "Checking Hyprland dotfiles runtime tools"

  for tool in "${required[@]}"; do
    if command_exists "$tool"; then
      log_ok "$tool found"
    else
      log_warn "$tool not found; hyprland-dotfiles will not install packages automatically"
      missing+=("$tool")
    fi
  done

  if ! command_exists Hyprland; then
    log_warn "Hyprland is missing; this profile only deploys dotfiles and will not install it"
  fi

  if [[ "${#missing[@]}" -gt 0 ]]; then
    log_warn "Missing tools: ${missing[*]}"
  fi
}

install_hyprland_dotfiles() {
  hyprland_dotfiles_preflight
  log_info "Installing Hyprland managed dotfiles"
  install_config_dir "hypr" "$HOME/.config/hypr"
  install_config_dir "waybar" "$HOME/.config/waybar"
  install_config_dir "rofi" "$HOME/.config/rofi"
  install_config_dir "hyprlock" "$HOME/.config/hyprlock"
  install_config_dir "wlogout" "$HOME/.config/wlogout"
}

run_profile() {
  local profile="$1"
  case "$profile" in
    common) install_package_profile "common" ;;
    cachyos) install_package_profile "cachyos" ;;
    gaming) install_package_profile "gaming" ;;
    hyprland) install_package_profile "hyprland" ;;
    hyprland-dotfiles) install_hyprland_dotfiles ;;
    development) install_package_profile "development" ;;
    dotfiles) install_dotfiles ;;
    full)
      install_package_profile "common"
      install_package_profile "cachyos"
      install_package_profile "gaming"
      install_package_profile "hyprland"
      install_package_profile "development"
      install_dotfiles
      ;;
    *) die "Unknown profile: $profile" ;;
  esac
}

show_menu() {
  cat <<MENU
====================================
Luciano Dotfiles
====================================

Sistema detectado: ${DISTRO_PRETTY_NAME:-unknown}

1. Configuración común
2. CachyOS
3. Gaming
4. Hyprland
5. Desarrollo
6. Instalación completa
7. Solo dotfiles
8. Hyprland dotfiles
9. Salir
MENU
}

menu_loop() {
  local choice
  while true; do
    show_menu
    read -r -p "Selecciona una opción: " choice
    case "$choice" in
      1) run_profile common ;;
      2) run_profile cachyos ;;
      3) run_profile gaming ;;
      4) run_profile hyprland ;;
      5) run_profile development ;;
      6) run_profile full ;;
      7) run_profile dotfiles ;;
      8) run_profile hyprland-dotfiles ;;
      9) log_info "Saliendo"; exit 0 ;;
      *) log_warn "Opción no válida" ;;
    esac
  done
}

main() {
  local profile=""

  while (($#)); do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      -h|--help) usage; exit 0 ;;
      *) profile="$1" ;;
    esac
    shift
  done

  require_not_root
  detect_distro
  detect_package_tools

  if [[ "$DRY_RUN" -eq 1 ]]; then
    log_warn "Dry-run enabled: no files or packages will be changed"
  fi

  if [[ -n "$profile" ]]; then
    run_profile "$profile"
  else
    menu_loop
  fi
}

main "$@"
