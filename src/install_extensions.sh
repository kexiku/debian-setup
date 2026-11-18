#!/bin/bash
set -euo pipefail

# Define required variables
ROOT_DIR="${ROOT_DIR:-$(dirname "$(realpath "${BASH_SOURCE[0]}")/..")}"
MANIFEST="${MANIFEST:-${ROOT_DIR}/data/manifest.json}"

# Load lib files
source "${ROOT_DIR}/lib/config.sh"
source "${ROOT_DIR}/lib/helpers.sh"

check_root
check_package jq
check_package pipx
check_python_app gnome-extensions-cli

pipx ensurepath

# Define extensions array
mapfile -t extensions < <(jq -r '.extensions[]' "$MANIFEST")

# Check if extension list is empty
if (( ${#extensions[@]} == 0 )); then
  print_error "No Gnome extensions listed in ${MANIFEST}" >&2
  exit 1
fi

print_extensions() {
  local extension

  for extension in "${extensions[@]}"; do
    printf '* %s%s%s\n' "$CYAN" "$extension" "$RESET"
  done
}

install_extensions() {
  gext install "${extensions[@]}"
}

echo -e "\nThe script is about to install the following Gnome extensions:"
print_extensions

read -rp $'\nProceed to the installation? [Y/n] ' ans
if [[ "${ans:-y}" =~ ^[Yy]$ ]]; then
  install_extensions
else
  print_warning "Cancelled."
  exit 0
fi

echo "Done!"
