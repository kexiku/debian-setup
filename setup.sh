#!/bin/bash
set -e

resolve_symlinks() {
  SOURCE="${BASH_SOURCE[0]}"

  while [ -L "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
  done

  SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
  PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

  export PROJECT_ROOT
}

resolve_symlinks

source $PROJECT_ROOT/lib/os_checker.sh

detect_distro

source $PROJECT_ROOT/lib/menu.sh
source $PROJECT_ROOT/lib/packages.sh
source $PROJECT_ROOT/lib/flatpaks.sh

call_menu
