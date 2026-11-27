[[ -n "${_LIB_VALIDATION_LOADED:-}" ]] && return || _LIB_VALIDATION_LOADED=1

source "${ROOT_DIR}/lib/config.sh"
source "${ROOT_DIR}/lib/print.sh"

validate_array() {
  local arr="$1"
  local error_msg

  error_msg=$(jq -r --arg arr "$arr" '
    if has($arr) | not then
      "Missing the \"\($arr)\" array."
    elif .[$arr] | type != "array" then
      "\"\($arr)\" is not a valid array."
    elif .[$arr] | length == 0 then
      "The \"\($arr)\" array is empty."
    elif .[$arr] | any(has("id")) and (all(.id | type == "string" and length > 0) | not) then
      "Invalid id value in one or more \"\($arr)\" entries."
    else
      empty
    end
    ' "$MANIFEST")

  if [[ -n $error_msg ]]; then
    print_error "${MANIFEST}: ${error_msg}" >&2
    return 1
  fi
}
