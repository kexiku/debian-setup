#!/bin/bash
set -euo pipefail

# Define required variables
ROOT_DIR="${ROOT_DIR:-$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")}"
MANIFEST="${MANIFEST:-${ROOT_DIR}/data/manifest.json}"

# Load lib files
source "${ROOT_DIR}/lib/config.sh"
source "${ROOT_DIR}/lib/helpers.sh"

check_root
check_package jq
check_package pipx

export PATH="${HOME}/.local/bin:${PATH}"

check_python_app gnome-extensions-cli

# Check if extension list is empty
has_extensions=$(jq -r '.extensions | length > 0' "$MANIFEST")

if ! $has_extensions; then
  print_error "${MANIFEST}: The \"extensions\" array is empty." >&2
  exit 1
fi

# Check for invalid ids
has_ids=$(jq -r '.extensions | all(.id | type == "string" and length > 0)' "$MANIFEST")

if ! $has_ids; then
  print_error "${MANIFEST}: Invalid or missing \"id\" value in \"extensions\"." >&2
  exit 1
fi

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
