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

extract_route_families() {
  awk '
    /@route_key_requirements %\{/ { in_block = 1; next }
    in_block && /}/ { in_block = 0 }
    in_block {
      if (match($0, /([a-z_]+):[[:space:]]*\[/)) {
        family = substr($0, RSTART, RLENGTH)
        sub(/:.*/, "", family)
        print family
      }
    }
  ' "$WIDGET_REGISTRY_FILE" | sort -u
}

extract_route_family_pairs() {
  awk '
    /@route_key_requirements %\{/ { in_block = 1; next }
    in_block && /}/ { in_block = 0; current_family = "" }
    in_block {
      if (match($0, /([a-z_]+):[[:space:]]*\[/)) {
        current_family = substr($0, RSTART, RLENGTH)
        sub(/:.*/, "", current_family)
      }

      if (current_family != "") {
        line = $0
        while (match(line, /"[^"]+"/)) {
          route_key = substr(line, RSTART + 1, RLENGTH - 2)
          print current_family "|" route_key
          line = substr(line, RSTART + RLENGTH)
        }
      }
    }
  ' "$WIDGET_REGISTRY_FILE" | sort -u
}

expected_source_for_key() {
  local route_key="$1"

  case "$route_key" in
    action|widget_id)
      echo "widget_event_contract"
      ;;
    button_id|id|input_id|field|form_id)
      echo "route_key_contract"
      ;;
    *)
      echo ""
      ;;
  esac
}

require_file "$WIDGET_REGISTRY_FILE"
require_file "$ELM_FILE"
require_file "$BRIDGE_FILE"

ROUTE_FAMILIES="$(extract_route_families)"
ROUTE_FAMILY_PAIRS="$(extract_route_family_pairs)"

if [[ -z "$ROUTE_FAMILIES" ]]; then
  echo "ERROR: unable to extract route families from $WIDGET_REGISTRY_FILE"
  exit 1
fi

if [[ -z "$ROUTE_FAMILY_PAIRS" ]]; then
  echo "ERROR: unable to extract route-family route-key pairs from $WIDGET_REGISTRY_FILE"
  exit 1
fi

echo "Validating frontend widget event route-key source-requirements parity..."

while IFS= read -r route_family; do
  [[ -z "$route_family" ]] && continue

  if ! file_contains_literal "\"$route_family\"" "$ELM_FILE"; then
    fail "Elm harness missing canonical route family '$route_family'"
  fi

  if ! file_contains_literal "\"$route_family\"" "$BRIDGE_FILE"; then
    fail "JS bridge missing canonical route family '$route_family'"
  fi
done <<< "$ROUTE_FAMILIES"

while IFS='|' read -r route_family route_key; do
  [[ -z "$route_family" || -z "$route_key" ]] && continue

  expected_source="$(expected_source_for_key "$route_key")"

  if [[ -z "$expected_source" ]]; then
    fail "Unknown canonical route-key source convention for key '$route_key'"
    continue
  fi

  if ! file_contains_literal "( \"$route_key\", \"$expected_source\" )" "$ELM_FILE"; then
    fail "Elm harness missing canonical route-key source requirement '$route_key -> $expected_source'"
  fi

  if ! file_contains_literal "$route_key: \"$expected_source\"" "$BRIDGE_FILE"; then
    fail "JS bridge missing canonical route-key source requirement '$route_key -> $expected_source'"
  fi
done <<< "$ROUTE_FAMILY_PAIRS"

if ! file_contains_literal "canonicalRouteKeySourceRequirements" "$ELM_FILE"; then
  fail "Elm harness missing canonical route-key source requirements map"
fi

if ! file_contains_literal "canonicalRouteKeySourceForFamily" "$ELM_FILE"; then
  fail "Elm harness missing route-family route-key source helper"
fi

if ! file_contains_literal "routeFamilyExpectedRouteKeySource" "$ELM_FILE"; then
  fail "Elm harness missing route-family expected route-key source helper"
fi

if ! file_contains_literal "CANONICAL_ROUTE_KEY_SOURCE_REQUIREMENTS" "$BRIDGE_FILE"; then
  fail "JS bridge missing canonical route-key source requirements map"
fi

if ! file_contains_literal "analyzeRouteKeySourceRequirements" "$BRIDGE_FILE"; then
  fail "JS bridge missing route-key source-requirements analysis helper"
fi

if ! file_contains_literal "missing_route_key_source_requirements" "$BRIDGE_FILE"; then
  fail "JS bridge missing missing route-key source requirement diagnostics"
fi

if ! file_contains_literal "invalid_route_key_source_requirements" "$BRIDGE_FILE"; then
  fail "JS bridge missing invalid route-key source requirement diagnostics"
fi

if ! file_contains_literal "canonical route_key source requirements drift for route family" "$BRIDGE_FILE"; then
  fail "JS bridge missing canonical route-key source requirement drift reason"
fi

if [[ "$failures" -ne 0 ]]; then
  echo
  echo "Frontend widget event route-key source-requirements validation failed."
  exit 1
fi

echo "Frontend widget event route-key source-requirements validation passed."
