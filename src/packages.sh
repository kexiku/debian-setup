#!/bin/bash
set -euo pipefail

source "${ROOT_DIR}/lib/helpers.sh"

check_package jq

packages=($(jq -r '.packages[]' "$MANIFEST"))

echo "List of packages:"
printf '* \033[0;33m%s\033[0m\n' "${packages[@]}"

read -rp "Proceed to the installation? [Y/n] " ans
if [[ -z "$ans" || "$ans" =~ ^[Yy]$ ]]; then
  sudo apt update
  sudo apt install -y "${packages[@]}"
else
  echo "Installation aborted."
  exit 1
fi
