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

check_root() {
  if [[ $EUID -eq 0 ]]; then
    print_error "The script should not be run as root." >&2
    return 1
  fi
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

check_python_app() {
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

request_logout() {
  case "${XDG_CURRENT_DESKTOP,,}" in
    *gnome*)    gnome-session-quit --logout ;;
    *xfce*)     xfce4-session-logout --logout ;;
    *kde*)      qdbus6 org.kde.Shutdown /Shutdown logout 2>/dev/null \
             || qdbus org.kde.Shutdown /Shutdown logout ;;
    *cinnamon*) cinnamon-session-quit --logout ;;
    *mate*)     mate-session-save --logout ;;
    *lxqt*)	    lxqt-leave --logout ;;
    *sway*)     swaymsg exit ;;
    *i3*)       i3-msg exit ;;
    *)          loginctl terminate-session "${XDG_SESSION_ID:-}" ;;
    esac
}
