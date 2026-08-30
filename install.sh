#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

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
  ./install.sh [--dry-run] [common|cachyos|gaming|hyprland|development|dotfiles|full]

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

run_profile() {
  local profile="$1"
  case "$profile" in
    common) install_package_profile "common" ;;
    cachyos) install_package_profile "cachyos" ;;
    gaming) install_package_profile "gaming" ;;
    hyprland) install_package_profile "hyprland" ;;
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
8. Salir
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
      8) log_info "Saliendo"; exit 0 ;;
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
