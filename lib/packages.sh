#!/bin/bash

source $PROJECT_ROOT/lib/menu.sh
source $PROJECT_ROOT/lib/strings.sh
source $PROJECT_ROOT/lib/validation.sh

install_packages() {
  check_sources_file
  check_jq

  packages=($(jq -r '.packages[]' "$PROJECT_ROOT/data/sources.json"))

  echo "📜 List of packages:"
  printf ' * %s\n' "${packages[@]}"
  echo -e "$divider"

  sudo apt install "${packages[@]}"

  repeat_question
}

repeat_question() {
  echo -e "$divider"
  echo -e "🐍 Would you like to do something else? \n"

  call_menu
}
