#!/bin/bash
set -euo pipefail

source "${ROOT_DIR}/lib/helpers.sh"

check_package jq

packages=($(jq -r '.packages[]' "$MANIFEST"))

if [[ ${#packages[@]} == 0 ]]; then
  echo "No packages listed in ${MANIFEST}, exiting without changes."
  exit 0
fi

echo "The script is about to install the following apt packages on your system:"
printf '* \033[0;33m%s\033[0m\n' "${packages[@]}"

read -rp "Proceed to the installation? [Y/n] " ans
if [[ -z "$ans" || "$ans" =~ ^[Yy]$ ]]; then
  sudo apt update
  sudo apt install -y "${packages[@]}"
else
  echo "Installation aborted."
  exit 1
fi
