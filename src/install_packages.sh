#!/bin/bash
set -euo pipefail

# Find script directory
ROOT_DIR="${ROOT_DIR:-$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")}"

# Load lib files
for lib in "${ROOT_DIR}"/lib/*.sh; do
  source "$lib"
done

prevent_root
require_package jq

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
