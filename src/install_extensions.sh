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

# Check if extension list is empty
no_extensions=$(jq -r '.extensions | length == 0' "$MANIFEST")

if $no_extensions; then
  print_error "No Gnome extensions listed in ${MANIFEST}" >&2
  exit 1
fi

list_extensions() {
  jq -r '.extensions[]
    | [(.name // .id), .id]
    | @tsv' "$MANIFEST"
}

print_extensions() {
  local name id

  while IFS=$'\t' read -r name id; do
    printf '* %s%s%s (%s)\n' "$CYAN" "$name" "$RESET" "$id"
  done < <(list_extensions)
}

install_extensions() {
  local name id

  while IFS=$'\t' read -r name id; do
    gext install $id
  done < <(list_extensions)
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
