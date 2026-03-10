#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

WIDGET_REGISTRY_FILE="lib/web_ui/widget_registry.ex"
ELM_FILE="assets/src/Main.elm"
BRIDGE_FILE="assets/js/app.js"

failures=0

fail() {
  echo "FAIL: $1"
  failures=1
}

require_file() {
  local path="$1"

  if [[ ! -f "$path" ]]; then
    echo "ERROR: missing required file: $path"
    exit 1
  fi
}

has_rg() {
  command -v rg >/dev/null 2>&1
}

file_contains_literal() {
  local needle="$1"
  shift

  if has_rg; then
    rg -Fq -- "$needle" "$@"
  else
    grep -Fq -- "$needle" "$@"
  fi
}

extract_route_requirements() {
  awk '
    /@route_key_requirements %\{/ { in_block = 1; next }
    in_block && /}/ { in_block = 0 }
    in_block {
      if (match($0, /([a-z_]+):[[:space:]]*\[/)) {
        family = substr($0, RSTART, RLENGTH)
        sub(/:.*/, "", family)

        line = $0
        keys = ""

        while (match(line, /"[^"]+"/)) {
          key = substr(line, RSTART + 1, RLENGTH - 2)
          keys = keys key ","
          line = substr(line, RSTART + RLENGTH)
        }

        sub(/,$/, "", keys)
        print family "|" keys
      }
    }
  ' "$WIDGET_REGISTRY_FILE"
}

format_key_list() {
  local csv="$1"
  local style="${2:-spaced}"
  local formatted="[ "
  local first=1

  if [[ "$style" == "compact" ]]; then
    formatted="["
  fi

  IFS=',' read -r -a keys <<< "$csv"

  for key in "${keys[@]}"; do
    [[ -z "$key" ]] && continue

    if [[ "$first" -eq 0 ]]; then
      formatted+=", "
    fi

    formatted+="\"$key\""
    first=0
  done

  if [[ "$style" == "compact" ]]; then
    formatted+="]"
  else
    formatted+=" ]"
  fi

  printf "%s" "$formatted"
}

require_file "$WIDGET_REGISTRY_FILE"
require_file "$ELM_FILE"
require_file "$BRIDGE_FILE"

ROUTE_REQUIREMENTS="$(extract_route_requirements)"

if [[ -z "$ROUTE_REQUIREMENTS" ]]; then
  echo "ERROR: unable to extract route requirements from $WIDGET_REGISTRY_FILE"
  exit 1
fi

echo "Validating frontend widget event route-key ordering continuity..."

while IFS='|' read -r route_family route_keys_csv; do
  [[ -z "$route_family" || -z "$route_keys_csv" ]] && continue

  elm_key_list="$(format_key_list "$route_keys_csv")"
  js_key_list="$(format_key_list "$route_keys_csv" compact)"
  elm_literal="( \"$route_family\", $elm_key_list )"
  js_literal="$route_family: $js_key_list"

  if ! file_contains_literal "$elm_literal" "$ELM_FILE"; then
    fail "Elm harness missing canonical ordered route-key list for family '$route_family'"
  fi

  if ! file_contains_literal "$js_literal" "$BRIDGE_FILE"; then
    fail "JS bridge missing canonical ordered route-key list for family '$route_family'"
  fi
done <<< "$ROUTE_REQUIREMENTS"

if ! file_contains_literal "List.foldl (appendIfRouteKeyPopulated model) []" "$ELM_FILE"; then
  fail "Elm harness missing ordered route-key fold helper wiring"
fi

if ! file_contains_literal "List.reverse" "$ELM_FILE"; then
  fail "Elm harness missing ordered route-key reversal step"
fi

if ! file_contains_literal "duplicateStrings" "$BRIDGE_FILE"; then
  fail "JS bridge missing duplicate route-keys detection helper"
fi

if ! file_contains_literal "duplicate_route_keys" "$BRIDGE_FILE"; then
  fail "JS bridge missing duplicate route-keys diagnostics"
fi

if file_contains_literal "[...presentRouteKeys].sort()" "$BRIDGE_FILE"; then
  fail "JS bridge should not sort expected route_keys when enforcing canonical order continuity"
fi

if file_contains_literal "[...declaredRouteKeys].sort()" "$BRIDGE_FILE"; then
  fail "JS bridge should not sort declared route_keys when enforcing canonical order continuity"
fi

if ! file_contains_literal "expectedRouteKeys.every((expectedKey, index) => expectedKey === actualRouteKeys[index])" "$BRIDGE_FILE"; then
  fail "JS bridge missing ordered route-keys equality check"
fi

if [[ "$failures" -ne 0 ]]; then
  echo
  echo "Frontend widget event route-key ordering validation failed."
  exit 1
fi

echo "Frontend widget event route-key ordering validation passed."
