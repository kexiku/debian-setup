#!/bin/bash
set -euo pipefail

for lib in "${ROOT_DIR}"/lib/*.sh; do
  source "$lib"
done

validate_array packages

mapfile -t packages < <(jq -r '.packages[].name' "$MANIFEST")

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
