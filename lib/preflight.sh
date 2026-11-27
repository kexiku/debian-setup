[[ -n "${_LIB_PREFLIGHT_LOADED:-}" ]] && return || _LIB_PREFLIGHT_LOADED=1

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

is_pkg_installed() {
  local status
  status=$(dpkg-query -W -f='${db:Status-Abbrev}' "$1" 2>/dev/null)

  [[ $status == ii* ]]
}

install_dependencies() {
  local -a missing=()
  local pkg ans

  for pkg in "${DEPENDENCIES[@]}"; do
    is_pkg_installed "$pkg" || missing+=("$pkg")
  done

  (( ${#missing[@]} == 0 )) && return 0

  print_header "This script requires the following apt package(s) to be installed:"

  for pkg in "${missing[@]}"; do
    printf '* %s%s%s\n' "$GREEN" "$pkg" "$RESET"
  done

  read -rp $'\nProceed to the installation? [Y/n] ' ans
  if [[ "${ans:-y}" =~ ^[Yy]$ ]]; then
    sudo apt update
    sudo apt install -y "${missing[@]}"
  else
    print_error "Missing required dependencies." >&2
    return 1
  fi
}
