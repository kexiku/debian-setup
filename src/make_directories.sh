#!/bin/bash
set -euo pipefail

# Find script directory
ROOT_DIR="${ROOT_DIR:-$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")}"

for lib in "${ROOT_DIR}"/lib/*.sh; do
  source "$lib"
done

prevent_root
require_package jq

list_directories() {
  jq -r \
    --arg home   "$HOME" \
    --arg config "${XDG_CONFIG_HOME:-$HOME/.config}" \
    --arg cache  "${XDG_CACHE_HOME:-$HOME/.cache}" \
    --arg data   "${XDG_DATA_HOME:-$HOME/.local/share}" \
    --arg state  "${XDG_STATE_HOME:-$HOME/.local/state}" '
    {home: $home, config: $config, cache: $cache, data: $data, state: $state} as $base
    | .directories[]
    | "\($base[.location])/\(.name)"
  ' "$MANIFEST"
}

# Check if directory list is empty
mapfile -t directories < <(list_directories)

if (( ${#directories[@]} == 0)); then
  print_error "No directories listed in ${MANIFEST}" >&2
  exit 1
fi

print_directories() {
  local dir

  for dir in "${directories[@]}"; do
    printf '* %s%s%s\n' "$YELLOW" "$dir" "$RESET"
  done
}

make_directories() {
  mkdir -pv "${directories[@]}"
}

echo -e "\nThe script will create the following directories:"
print_directories

read -rp $'\nContinue? [Y/n] ' ans
if [[ "${ans:-y}" =~ ^[Yy]$ ]]; then
  make_directories
else
  print_warning "Cancelled."
  exit 0
fi

echo "Done!"
