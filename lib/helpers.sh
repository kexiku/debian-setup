check_package() {
  local pkg="$1"

  # Return if package is installed
  command -v "$pkg" >/dev/null 2>&1 && return 0

  echo "This script requires ${pkg} package to run."

  read -rp "Would you like to install it now? [Y/n] " ans
  if [[ -z "$ans" || "$ans" =~ ^[Yy]$ ]]; then
    sudo apt install -y "$pkg"
  else
    echo "Error: missing required ${pkg} package." >&2
    return 1
  fi
}
