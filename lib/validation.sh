[[ -n "${_LIB_VALIDATION_LOADED:-}" ]] && return || _LIB_VALIDATION_LOADED=1

source "${ROOT_DIR}/lib/config.sh"
source "${ROOT_DIR}/lib/print.sh"

validate_array() {
  local arr="$1"
  local is_missing is_empty has_ids is_bad_id msg

  is_missing=$(jq -r --arg arr "$arr" 'has($arr) | not' "$MANIFEST")
  is_empty=$(jq -r --arg arr "$arr" '.[$arr] | length == 0' "$MANIFEST")
  has_ids=$(jq -r --arg arr "$arr" '.[$arr] | any(has("id"))' "$MANIFEST")
  is_bad_id=$(jq -r --arg arr "$arr" '.[$arr] | all(.id | type == "string" and length > 0) | not' "$MANIFEST")

  if $is_missing; then
    msg="Missing the \"${arr}\" array."
  elif $is_empty; then
    msg="The \"${arr}\" array is empty."
  elif $has_ids && $is_bad_id; then
    msg="Invalid id value in one or more \"${arr}\" entries."
  else
    return 0
  fi

  print_error "${MANIFEST}: ${msg}" >&2
  return 1
}
