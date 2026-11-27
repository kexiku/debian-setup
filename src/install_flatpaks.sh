#!/bin/bash
set -euo pipefail

for lib in "${ROOT_DIR}"/lib/*.sh; do
  source "$lib"
done

validate_array flatpaks

print_flatpaks() {
  jq -r \
  --arg c "$BLUE" \
  --arg r "$RESET" '
  .flatpaks[]
  | "* \($c)\(.name // .id)\($r) (\(.id)) from \($c)\(.remote // "flathub")\($r)"' "$MANIFEST"
}

install_flatpaks() {
  local remote name id

  # Add Flathub repo
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

  while IFS=$'\t' read -r remote id; do
    flatpak install --system -y "$remote" "$id"
  done < <(jq -r '.flatpaks[]
    | [(.remote // "flathub"), .id]
    | @tsv' "$MANIFEST")
}

echo -e "\nThe script is about to install the following Flatpak apps:"
print_flatpaks

read -rp $'\nProceed to the installation? [Y/n] ' ans
if [[ "${ans:-y}" =~ ^[Yy]$ ]]; then
  install_flatpaks
else
  print_warning "Cancelled."
  exit 0
fi

echo "A session restart is required for installed apps to be appeared on your desktop."
read -rp 'Log out now? [Y/n] ' ans
if [[ "${ans:-y}" =~ ^[Yy]$ ]]; then
  request_logout
else
  echo "Skipping session restart."
fi

echo "Done!"
