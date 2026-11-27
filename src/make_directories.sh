#!/bin/bash
set -euo pipefail

for lib in "${ROOT_DIR}"/lib/*.sh; do
  source "$lib"
done

validate_array directories

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

mapfile -t directories < <(list_directories)

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
