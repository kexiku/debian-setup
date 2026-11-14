#!/bin/bash
set -euo pipefail

source "${ROOT_DIR}/lib/helpers.sh"

check_package flatpak
check_package jq

echo "List of Flatpak apps:"
jq -r '.flatpaks[] | "* \(.name) (\(.id))"' "$PROJECT_ROOT/data/sources.json"

jq -c '.flatpaks[]' "$PROJECT_ROOT/data/sources.json" | while read -r app; do
  remote=$(echo "$app" | jq -r '.remote')
  id=$(echo "$app" | jq -r '.id')

  flatpak install --system "$remote" "$id"
done
