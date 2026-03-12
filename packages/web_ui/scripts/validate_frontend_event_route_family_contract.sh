#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

EVENT_CATALOG_FILE="lib/web_ui/events/event_catalog.ex"
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

extract_event_route_pairs() {
  awk '
    {
      line = $0
      if (match(line, /"unified\.[a-z_]+(\.[a-z_]+)+"/) && line ~ /=>/) {
        event_type = substr(line, RSTART + 1, RLENGTH - 2)
      }

      if (event_type != "" && match(line, /route_family:[[:space:]]*:([a-z_]+)/)) {
        route_family = substr(line, RSTART, RLENGTH)
        sub(/^route_family:[[:space:]]*:/, "", route_family)
        print event_type "|" route_family
        event_type = ""
      }
    }
  ' "$EVENT_CATALOG_FILE" | sort -u
}

require_file "$EVENT_CATALOG_FILE"
require_file "$ELM_FILE"
require_file "$BRIDGE_FILE"

EVENT_ROUTE_PAIRS="$(extract_event_route_pairs)"

if [[ -z "$EVENT_ROUTE_PAIRS" ]]; then
  echo "ERROR: unable to extract event route-family pairs from $EVENT_CATALOG_FILE"
  exit 1
fi

echo "Validating frontend widget event route-family continuity parity..."

while IFS='|' read -r event_type route_family; do
  [[ -z "$event_type" || -z "$route_family" ]] && continue

  if ! file_contains_literal "( \"$event_type\", \"$route_family\" )" "$ELM_FILE"; then
    fail "Elm harness missing canonical route-family tuple '$event_type -> $route_family'"
  fi

  if ! file_contains_literal "\"$event_type\": \"$route_family\"" "$BRIDGE_FILE"; then
    fail "JS bridge missing canonical route-family mapping '$event_type -> $route_family'"
  fi
done <<< "$EVENT_ROUTE_PAIRS"

if ! file_contains_literal "routeFamilyForEventType defaultWidgetEventType" "$ELM_FILE"; then
  fail "Elm harness missing default route-family derivation from canonical event-type mapping"
fi

if ! file_contains_literal "\"route_family\"" "$ELM_FILE"; then
  fail "Elm harness missing route_family payload key wiring"
fi

if ! file_contains_literal "( \"route_family\", Encode.string defaultWidgetEventRouteFamily )" "$ELM_FILE"; then
  fail "Elm harness missing route_family continuity payload field"
fi

if ! file_contains_literal "declaredRouteFamily" "$BRIDGE_FILE"; then
  fail "JS bridge missing route_family continuity variable extraction"
fi

if ! file_contains_literal "transport.invalid_widget_event_route_family" "$BRIDGE_FILE"; then
  fail "JS bridge missing typed invalid widget route-family error code"
fi

if ! file_contains_literal "expected_route_family" "$BRIDGE_FILE"; then
  fail "JS bridge missing expected route-family diagnostics"
fi

if ! file_contains_literal "actual_route_family" "$BRIDGE_FILE"; then
  fail "JS bridge missing actual route-family mismatch diagnostics"
fi

if [[ "$failures" -ne 0 ]]; then
  echo
  echo "Frontend widget event route-family contract validation failed."
  exit 1
fi

echo "Frontend widget event route-family contract validation passed."
