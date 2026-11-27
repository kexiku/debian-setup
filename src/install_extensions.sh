#!/bin/bash
set -euo pipefail

# Find script directory
ROOT_DIR="${ROOT_DIR:-$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")}"

for lib in "${ROOT_DIR}"/lib/*.sh; do
  source "$lib"
done

prevent_root
require_package jq
require_package pipx

# Update $PATH to include pipx default binary location
export PATH="${PIPX_BIN_DIR:-${HOME}/.local/bin}:$PATH"

require_python_app gnome-extensions-cli
validate_array extensions

print_extensions() {
  jq -r \
  --arg c "$CYAN" \
  --arg r "$RESET" '
  .extensions[]
  | "* \($c)\(.name // .id)\($r) (\(.id))"' "$MANIFEST"
}

install_extensions() {
  local -a ids
  mapfile -t ids < <(jq -r '.extensions[].id' "$MANIFEST")

  gext install "${ids[@]}"
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
