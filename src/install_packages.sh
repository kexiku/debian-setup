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

# Define packages array
mapfile -t packages < <(jq -r '.packages[]' "$MANIFEST")

# Check if package list is empty
if (( ${#packages[@]} == 0 )); then
  print_error "No apt packages listed in ${MANIFEST}" >&2
  exit 1
fi

print_packages() {
  local package

  for package in "${packages[@]}"; do
    printf '* %s%s%s\n' "$GREEN" "$package" "$RESET"
  done
}

install_packages() {
  sudo apt update
  sudo apt install -y "${packages[@]}"
}

echo -e "\nThe script is about to install the following apt packages on your system:"
print_packages

read -rp $'\nProceed to the installation? [Y/n] ' ans
if [[ "${ans:-y}" =~ ^[Yy]$ ]]; then
  install_packages
else
  print_warning "Cancelled."
  exit 0
fi

echo "Done!"
