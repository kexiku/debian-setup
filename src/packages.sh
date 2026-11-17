#!/bin/bash
set -euo pipefail

# Load lib files
source "${ROOT_DIR}/lib/config.sh"
source "${ROOT_DIR}/lib/helpers.sh"

# Check dependencies
check_package jq

# Load packages list
packages=($(jq -r '.packages[]' "$MANIFEST"))

if [[ ${#packages[@]} == 0 ]]; then
  print_error "No apt packages listed in ${MANIFEST}" >&2
  exit 1
fi

echo -e "\nThe script is about to install the following apt packages on your system:"

for package in "${packages[@]}"; do
  printf '* %s%s%s\n' "$GREEN" "$package" "$RESET"
done

read -rp $'\nProceed to the installation? [Y/n] ' ans
if [[ -z "$ans" || "$ans" =~ ^[Yy]$ ]]; then
  sudo apt update
  sudo apt install -y "${packages[@]}"
else
  print_error "Installation aborted." >&2
  exit 1
fi
