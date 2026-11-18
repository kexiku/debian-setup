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

list_directories() {
  jq -r \
    --arg home   "$HOME" \
    --arg config "${XDG_CONFIG_HOME:-$HOME/.config}" \
    --arg cache  "${XDG_CACHE_HOME:-$HOME/.cache}" \
    --arg data   "${XDG_DATA_HOME:-$HOME/.local/share}" \
    --arg state  "${XDG_STATE_HOME:-$HOME/.local/state}" '
    {home: $home, config: $config, cache: $cache, data: $data, state: $state} as $base
    | .directories[]
    | "\($base[.path])/\(.name)"
  ' "$MANIFEST"
}

# Define directories array
mapfile -t directories < <(list_directories)

# Check if directory list is empty
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
  local dir

  for dir in "${directories[@]}"; do
    mkdir -pv "$dir"
  done
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
