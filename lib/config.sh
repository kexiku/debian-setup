# Include guard
[[ -n "${_CONFIG_LOADED:-}" ]] && return || _CONFIG_LOADED=1

# Colors
if [[ -t 1 ]]; then
  RED=$'\033[0;91m'
  GREEN=$'\033[0;92m'
  YELLOW=$'\033[0;93m'
  BLUE=$'\033[0;94m'
  WHITE=$'\033[0;97m'

  BOLD_RED=$'\033[1;91m'
  BOLD_GREEN=$'\033[1;92m'
  BOLD_YELLOW=$'\033[1;93m'
  BOLD_BLUE=$'\033[1;94m'
  BOLD_WHITE=$'\033[1;97m'

  RESET=$'\033[0m'
else
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  WHITE=''

  BOLD_RED=''
  BOLD_GREEN=''
  BOLD_YELLOW=''
  BOLD_BLUE=''
  BOLD_WHITE=''

  RESET=''
fi
