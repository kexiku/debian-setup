#!/bin/bash
set -euo pipefail

for lib in "${ROOT_DIR}"/lib/*.sh; do
  source "$lib"
done

validate_array extensions

# Update $PATH to include pipx default binary location
export PATH="${PIPX_BIN_DIR:-${HOME}/.local/bin}:$PATH"

pipx install --system-site-packages gnome-extensions-cli

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
