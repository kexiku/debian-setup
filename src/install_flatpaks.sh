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
  print_error "No Flatpak apps listed in ${MANIFEST}" >&2
  exit 1
fi

# Check for missing ids
has_id=$(jq -r '.flatpaks | all(has("id") and .id != null)' "$MANIFEST")

if ! $has_id; then
  print_error "Missing 'id' value in one or more flatpak entries in ${MANIFEST}" >&2
  exit 1
fi

list_flatpaks() {
  jq -r '.flatpaks[]
    | [(.remote // "flathub"), (.name // .id), .id]
    | @tsv' "$MANIFEST"
}

print_flatpaks() {
  local remote name id

  while IFS=$'\t' read -r remote name id; do
    printf '* %s%s%s (%s) from %s%s%s\n' "$BLUE" "$name" "$RESET" "$id" "$BLUE" "$remote" "$RESET"
  done < <(list_flatpaks)
}

install_flatpaks() {
  local remote name id

  # Add Flathub repo
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

  while IFS=$'\t' read -r remote name id; do
    flatpak install --system -y "$remote" "$id"
  done < <(list_flatpaks)
}

echo -e "\nThe script is about to install the following Flatpak apps:"
print_flatpaks

read -rp $'\nProceed to the installation? [Y/n] ' ans
if [[ "${ans:-y}" =~ ^[Yy]$ ]]; then
  install_flatpaks
else
  print_error "Installation aborted." >&2
  exit 1
fi

echo "A session restart is required for installed apps to be appeared on your desktop."
read -rp 'Log out now? [Y/n] ' ans
if [[ "${ans:-y}" =~ ^[Yy]$ ]]; then
  request_logout
else
  echo "Skipping session restart."
fi

echo "Done!"
