# Include guard
[[ -n "${_PREFLIGHT_LOADED:-}" ]] && return || _PREFLIGHT_LOADED=1

# Load config
source "${ROOT_DIR}/lib/config.sh"
source "${ROOT_DIR}/lib/print.sh"

prevent_root() {
  if [[ $EUID -eq 0 ]]; then
    print_error "The script should not be run as root." >&2
    return 1
  fi
}

require_file() {
  if [[ ! -f "$1" ]]; then
    print_error "Cannot locate ${1}: file is missing." >&2
    return 1
  fi
}

require_package() {
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

require_python_app() {
  local app="$1"

  # Return if Python application is found
  pipx list --short | grep -q "^$app " && return 0

  printf 'This script requires %s%s%s Python application to be installed.\n' "$YELLOW" "$app" "$RESET"

  read -rp 'Would you like to install it now? [Y/n] ' ans
  if [[ "${ans:-y}" =~ ^[Yy]$ ]]; then
    pipx install --system-site-packages "$app"
  else
    print_error "Missing required ${app} application." >&2
    return 1
  fi
}
