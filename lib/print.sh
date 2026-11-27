[[ -n "${_LIB_PRINT_LOADED:-}" ]] && return || _LIB_PRINT_LOADED=1

source "${ROOT_DIR}/lib/config.sh"

print_header() {
  printf '\n%s%s%s\n' "$BOLD" "$1" "$RESET"
}

print_error() {
  printf '%s%s%s\n' "$BOLD_RED" "$1" "$RESET"
}

print_warning() {
  printf '%s%s%s\n' "$BOLD_YELLOW" "$1" "$RESET"
}
