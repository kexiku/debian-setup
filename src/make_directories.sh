#!/bin/bash
set -euo pipefail

# Load lib files
source "${ROOT_DIR}/lib/config.sh"
source "${ROOT_DIR}/lib/helpers.sh"

# Define base directories
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"

directories=(
  "${HOME}/Projects"
  "${HOME}/Torrents"
  "${XDG_CACHE_HOME}/mpd"
  "${XDG_CONFIG_HOME}/autostart"
  "${XDG_CONFIG_HOME}/mpd/playlists"
  "${HOME}/.local/bin"
  "${XDG_DATA_HOME}/applications"
  "${XDG_DATA_HOME}/fonts"
  "${XDG_DATA_HOME}/icons"
  "${XDG_STATE_HOME}/mpd"
)

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

echo -e "\nThe script will create the following directories in your home directory:"
print_directories

read -rp $'\nContinue? [Y/n] ' ans
if [[ "${ans:-y}" =~ ^[Yy]$ ]]; then
  make_directories
else
  print_error "Cancelled." >&2
  exit 1
fi

echo "Done!"
