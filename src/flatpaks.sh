#!/bin/bash
set -euo pipefail

# Load lib files
source "${ROOT_DIR}/lib/config.sh"
source "${ROOT_DIR}/lib/helpers.sh"

# Check dependencies
check_package flatpak
check_package jq

# Check if flatpak list is empty
no_flatpaks=$(jq -r '.flatpaks | length == 0' "$MANIFEST")

if $no_flatpaks; then
  print_error "No flatpak apps listed in ${MANIFEST}" >&2
  exit 1
fi

# Check for missing ids
has_id=$(jq -r '.flatpaks | all(has("id") and .id != null)' "$MANIFEST")

if ! $has_id; then
  print_error "Incomplete data: one or more flatpak entries in ${MANIFEST} are missing an 'id' value." >&2
  exit 1
fi

# Get tab-separated flatpaks list
list_flatpaks() {
  jq -r '.flatpaks[]
    | [(.remote // "flathub"), (.name // .id), .id]
    | @tsv' "$MANIFEST"
}

echo -e "\nThe script is about to install the following flatpak apps:"

while IFS=$'\t' read -r remote name id; do
  printf '* %s%s%s (%s) from %s%s%s\n' "$BLUE" "$name" "$RESET" "$id" "$BLUE" "$remote" "$RESET"
done < <(list_flatpaks)

read -rp $'\nProceed to the installation? [Y/n] ' ans
if [[ -z "$ans" || "$ans" =~ ^[Yy]$ ]]; then

  while IFS=$'\t' read -r remote name id; do
    flatpak install --system -y "$remote" "$id"
  done < <(list_flatpaks)
else
  print_error "Installation aborted." >&2
  exit 1
fi
