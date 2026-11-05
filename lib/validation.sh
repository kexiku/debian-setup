#!/bin/bash

source $PROJECT_ROOT/lib/strings.sh

check_sources_file() {
  if [[ ! -f "$PROJECT_ROOT/data/sources.json" ]]; then
    echo >&2 "🌹 '$PROJECT_ROOT/data/sources.json': file not found."
    echo -e "$cancellation"
    exit 1
  fi
}

check_jq() {
  command -v jq >/dev/null 2>&1 || {
    echo -e "🪔 This script requires the jq package to run.\n"

    read -p "Do you want to install it? [Y/n] " answer
    if [[ "$answer" =~ ^[Yy]$ || -z "$answer" ]]; then
      echo -e "$divider"
      sudo apt install jq
    else
      echo -e "$cancellation"
      exit 1
    fi
  }
}

check_flatpak() {
  command -v flatpak >/dev/null 2>&1 || {
    echo -e "🔮 Seems like Flatpak isn't installed on your system.\n"

    read -p "Would you like to install it now? [Y/n] " answer
    if [[ "$answer" =~ ^[Yy]$ || -z "$answer" ]]; then
      echo -e "$divider"
      sudo apt install flatpak
    else
      echo -e "$cancellation"
      exit 1
    fi
  }
}