#!/usr/bin/env bash

package_file_for_profile() {
  local profile="$1"
  printf '%s/packages/%s.txt' "$SCRIPT_DIR" "$profile"
}

read_package_file() {
  local file="$1"
  sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$file"
}

package_name() {
  local entry="$1"
  printf '%s\n' "${entry#aur:}"
}

is_aur_entry() {
  [[ "$1" == aur:* ]]
}

is_installed() {
  local pkg="$1"
  [[ -n "$PACMAN_BIN" ]] || return 1
  pacman -Qq "$pkg" >/dev/null 2>&1
}

install_package_profile() {
  local profile="$1"
  local file
  file="$(package_file_for_profile "$profile")"

  [[ -f "$file" ]] || die "Package profile not found: $file"
  [[ "$IS_ARCH_LIKE" -eq 1 ]] || die "Profile '$profile' currently supports CachyOS/Arch-like systems only"
  [[ -n "$PACMAN_BIN" ]] || die "pacman is required to install package profiles"

  local entry pkg pacman_missing=() aur_missing=()
  while IFS= read -r entry; do
    pkg="$(package_name "$entry")"
    if is_installed "$pkg"; then
      log_ok "$pkg already installed"
    elif is_aur_entry "$entry"; then
      aur_missing+=("$pkg")
    else
      pacman_missing+=("$pkg")
    fi
  done < <(read_package_file "$file")

  if [[ "${#pacman_missing[@]}" -eq 0 && "${#aur_missing[@]}" -eq 0 ]]; then
    log_ok "All packages in '$profile' are already installed"
    return 0
  fi

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    preview_missing_packages "$profile" "${pacman_missing[@]}" -- "${aur_missing[@]}"
    return 0
  fi

  if [[ "${#pacman_missing[@]}" -gt 0 ]]; then
    log_info "pacman packages to install for '$profile': ${pacman_missing[*]}"
    run_cmd sudo pacman -S --needed "${pacman_missing[@]}"
  fi

  if [[ "${#aur_missing[@]}" -gt 0 ]]; then
    if [[ -n "$AUR_HELPER" ]]; then
      log_info "AUR packages to install for '$profile': ${aur_missing[*]}"
      run_cmd "$AUR_HELPER" -S --needed "${aur_missing[@]}"
    else
      log_warn "Skipping AUR packages because paru/yay was not found: ${aur_missing[*]}"
    fi
  fi
}

preview_missing_packages() {
  local profile="$1"
  shift

  local pacman_packages=()
  local aur_packages=()
  local mode="pacman"
  local pkg

  for pkg in "$@"; do
    if [[ "$pkg" == "--" ]]; then
      mode="aur"
      continue
    fi

    if [[ "$mode" == "pacman" ]]; then
      pacman_packages+=("$pkg")
    else
      aur_packages+=("$pkg")
    fi
  done

  if [[ "${#pacman_packages[@]}" -gt 0 ]]; then
    log_dry "install repo packages for '$profile' with: sudo pacman -S --needed ${pacman_packages[*]}"
  fi

  if [[ "${#aur_packages[@]}" -gt 0 ]]; then
    if [[ -n "$AUR_HELPER" ]]; then
      log_dry "install AUR packages for '$profile' with: $AUR_HELPER -S --needed ${aur_packages[*]}"
    else
      log_dry "skip AUR packages for '$profile' because paru/yay was not found: ${aur_packages[*]}"
    fi
  fi
}
