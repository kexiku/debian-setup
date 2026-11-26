#!/bin/bash
set -euo pipefail

# Find script directory
ROOT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
export ROOT_DIR

# Load lib files
for lib in "${ROOT_DIR}"/lib/*.sh; do
  source "$lib"
done

prevent_root
require_file "$MANIFEST"

# Menu
printf '=== %s%s%s ===\n\n' "$BOLD_RED" "Debian Setup" "$RESET"

options=(
  "Install apt packages"
  "Install Flatpak apps"
  "Install Gnome extensions"
  "Create additional directories"
  "Quit (q)"
)

call_menu() {
  COLUMNS=1 # Prevent option list from splitting to multiple columns
  PS3=$'\nChoose an option (1-3): '

  select opt in "${options[@]}"; do
    case "$REPLY" in
      1) bash "${ROOT_DIR}/src/install_packages.sh"; break ;;
      2) bash "${ROOT_DIR}/src/install_flatpaks.sh"; break ;;
      3) bash "${ROOT_DIR}/src/install_extensions.sh"; break ;;
      4) bash "${ROOT_DIR}/src/make_directories.sh"; break ;;
      5|q) exit 0 ;;
      *) echo "Invalid option, enter the correct value (1-3)." ;;
    esac
  done

  printf 'Would you like to do something else?\n\n'
  call_menu
}

call_menu
