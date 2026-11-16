#!/bin/bash
set -euo pipefail

# Find script directory
ROOT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
export ROOT_DIR

# Check manifest file
MANIFEST="${ROOT_DIR}/data/manifest.json"

if [[ ! -f $MANIFEST ]]; then
  echo "Cannot locate $MANIFEST: file is missing." >&2
  exit 1
fi

export MANIFEST

printf '=== \033[0;31m%s\033[0m ===\n' "Debian Setup"

options=(
  "Install apt packages"
  "Install flatpaks"
  "Quit"
)

call_menu() {
  PS3=$'\nChoose an option (1-3): '
  printf "\n"

  select opt in "${options[@]}"; do
    case "$REPLY" in
      1) bash "${ROOT_DIR}/src/packages.sh"; break ;;
      2) bash "${ROOT_DIR}/src/flatpaks.sh"; break ;;
      3|q) exit 0 ;;
      *) echo "Invalid option, enter the correct value (1-3)." ;;
    esac
  done

  echo -e "\nWould you like to do something else?"
  call_menu
}

call_menu
