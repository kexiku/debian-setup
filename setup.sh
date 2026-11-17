#!/bin/bash
set -euo pipefail

# Find script directory
ROOT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
export ROOT_DIR

# Load lib files
source "${ROOT_DIR}/lib/config.sh"
source "${ROOT_DIR}/lib/helpers.sh"

# Define manifest file
MANIFEST="${ROOT_DIR}/data/manifest.json"

if [[ ! -f $MANIFEST ]]; then
  print_error "Cannot locate $MANIFEST: file is missing." >&2
  exit 1
fi

export MANIFEST

# Menu
printf '=== %s%s%s ===\n' "$BOLD_RED" "Debian Setup" "$RESET"

options=(
  "Install apt packages"
  "Install Flatpak apps"
  "Quit"
)

call_menu() {
  PS3=$'\nChoose an option (1-3): '
  printf "\n"

  select opt in "${options[@]}"; do
    case "$REPLY" in
      1) bash "${ROOT_DIR}/src/install_packages.sh"; break ;;
      2) bash "${ROOT_DIR}/src/install_flatpaks.sh"; break ;;
      3|q) exit 0 ;;
      *) echo "Invalid option, enter the correct value (1-3)." ;;
    esac
  done

  echo "Would you like to do something else?"
  call_menu
}

call_menu
