# Include guard
[[ -n "${_HELPERS_LOADED:-}" ]] && return || _HELPERS_LOADED=1

# Load config
source "${ROOT_DIR}/lib/config.sh"

print_error() {
  printf '%s%s%s\n' "$BOLD_RED" "$1" "$RESET"
}

print_warning() {
  printf '%s%s%s\n' "$BOLD_YELLOW" "$1" "$RESET"
}

check_package() {
  local pkg="$1"

  # Return if package is installed
  command -v "$pkg" >/dev/null 2>&1 && return 0

  printf 'This script requires %s%s%s package to be installed.\n' "$GREEN" "$pkg" "$RESET"

  read -rp 'Would you like to install it now? [Y/n] ' ans
  if [[ "${ans:-y}" =~ ^[Yy]$ ]]; then
    sudo apt update
    sudo apt install -y "$pkg"
  else
    print_error "Missing required ${pkg} package." >&2
    return 1
  fi
}
