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

extract_route_keys() {
  awk '
    /@route_key_requirements %\{/ { in_block = 1; next }
    in_block && /}/ { in_block = 0 }
    in_block {
      line = $0
      while (match(line, /"[^"]+"/)) {
        key = substr(line, RSTART + 1, RLENGTH - 2)
        print key
        line = substr(line, RSTART + RLENGTH)
      }
    }
  ' "$WIDGET_REGISTRY_FILE" | sort -u
}

require_file "$WIDGET_REGISTRY_FILE"
require_file "$ELM_FILE"
require_file "$BRIDGE_FILE"

ROUTE_FAMILIES="$(extract_route_families)"
ROUTE_KEYS="$(extract_route_keys)"

if [[ -z "$ROUTE_FAMILIES" ]]; then
  echo "ERROR: unable to extract route families from $WIDGET_REGISTRY_FILE"
  exit 1
fi

if [[ -z "$ROUTE_KEYS" ]]; then
  echo "ERROR: unable to extract route keys from $WIDGET_REGISTRY_FILE"
  exit 1
fi

echo "Validating frontend widget event route-key source triad parity..."

while IFS= read -r route_family; do
  [[ -z "$route_family" ]] && continue

  if ! file_contains_literal "\"$route_family\"" "$ELM_FILE"; then
    fail "Elm harness missing canonical route family '$route_family'"
  fi

  if ! file_contains_literal "\"$route_family\"" "$BRIDGE_FILE"; then
    fail "JS bridge missing canonical route family '$route_family'"
  fi
done <<< "$ROUTE_FAMILIES"

while IFS= read -r route_key; do
  [[ -z "$route_key" ]] && continue

  if ! file_contains_literal "\"$route_key\"" "$ELM_FILE"; then
    fail "Elm harness missing canonical route key '$route_key'"
  fi

  if ! file_contains_literal "\"$route_key\"" "$BRIDGE_FILE"; then
    fail "JS bridge missing canonical route key '$route_key'"
  fi
done <<< "$ROUTE_KEYS"

if ! file_contains_literal "declaredRouteKeySourceTriadParityKeys" "$ELM_FILE"; then
  fail "Elm harness missing route-key source triad parity key helper"
fi

if ! file_contains_literal "declaredRouteKeySourceTriadEntries" "$ELM_FILE"; then
  fail "Elm harness missing route-key source triad parity entry helper"
fi

if ! file_contains_literal "route_key_sources" "$ELM_FILE"; then
  fail "Elm harness missing route_key_sources payload continuity field"
fi

if ! file_contains_literal "route_key_source_keys" "$ELM_FILE"; then
  fail "Elm harness missing route_key_source_keys payload continuity field"
fi

if ! file_contains_literal "route_keys" "$ELM_FILE"; then
  fail "Elm harness missing route_keys payload continuity field"
fi

if ! file_contains_literal "analyzeRouteKeySourceTriadParity" "$BRIDGE_FILE"; then
  fail "JS bridge missing route-key source triad parity analysis helper"
fi

if ! file_contains_literal "route_key source triad parity mismatch for route family" "$BRIDGE_FILE"; then
  fail "JS bridge missing route-key source triad parity fail-closed reason"
fi

if ! file_contains_literal "route_key_source_key_mismatches" "$BRIDGE_FILE"; then
  fail "JS bridge missing route-key source-key mismatch diagnostics in triad parity errors"
fi

if ! file_contains_literal "route_key_source_map_key_mismatches" "$BRIDGE_FILE"; then
  fail "JS bridge missing route-key source-map mismatch diagnostics in triad parity errors"
fi

if ! file_contains_literal "source_key_source_map_key_mismatches" "$BRIDGE_FILE"; then
  fail "JS bridge missing source-key vs source-map mismatch diagnostics in triad parity errors"
fi

if ! file_contains_literal "transport.invalid_widget_event_route_keys" "$BRIDGE_FILE"; then
  fail "JS bridge missing typed invalid widget route_keys error code"
fi

if [[ "$failures" -ne 0 ]]; then
  echo
  echo "Frontend widget event route-key source triad parity validation failed."
  exit 1
fi

echo "Frontend widget event route-key source triad parity validation passed."
