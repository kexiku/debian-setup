# Include guard
[[ -n "${_PRINT_LOADED:-}" ]] && return || _PRINT_LOADED=1

# Load config
source "${ROOT_DIR}/lib/config.sh"

print_error() {
  printf '%s%s%s\n' "$BOLD_RED" "$1" "$RESET"
}

print_warning() {
  printf '%s%s%s\n' "$BOLD_YELLOW" "$1" "$RESET"
}
