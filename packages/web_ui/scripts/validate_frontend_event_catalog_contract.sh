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

extract_event_catalog_types() {
  awk '
    {
      line = $0
      while (match(line, /"unified\.[a-z_]+(\.[a-z_]+)+"/)) {
        event_name = substr(line, RSTART + 1, RLENGTH - 2)
        remainder = substr(line, RSTART + RLENGTH)
        if (remainder ~ /^[[:space:]]*=>/) {
          print event_name
        }
        line = remainder
      }
    }
  ' "$EVENT_CATALOG_FILE" | sort -u
}

extract_frontend_event_types() {
  local pattern='unified\.[a-z_]+(\.[a-z_]+)+'

  if has_rg; then
    rg -o --no-filename "$pattern" "$ELM_FILE" "$BRIDGE_FILE" | sort -u || true
  else
    grep -Eho "$pattern" "$ELM_FILE" "$BRIDGE_FILE" | sort -u || true
  fi
}

set_difference() {
  local left="$1"
  local right="$2"

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if ! echo "$right" | grep -Fxq "$line"; then
      echo "$line"
    fi
  done <<< "$left"
}

require_file "$EVENT_CATALOG_FILE"
require_file "$ELM_FILE"
require_file "$BRIDGE_FILE"

EXPECTED_EVENT_TYPES="$(extract_event_catalog_types)"
FRONTEND_EVENT_TYPES="$(extract_frontend_event_types)"

if [[ -z "$EXPECTED_EVENT_TYPES" ]]; then
  echo "ERROR: unable to extract canonical widget event types from $EVENT_CATALOG_FILE"
  exit 1
fi

echo "Validating frontend widget event catalog parity..."

while IFS= read -r event_type; do
  [[ -z "$event_type" ]] && continue

  if ! file_contains_literal "$event_type" "$ELM_FILE"; then
    fail "Elm harness missing canonical widget event type '$event_type'"
  fi

  if ! file_contains_literal "$event_type" "$BRIDGE_FILE"; then
    fail "JS bridge missing canonical widget event type '$event_type'"
  fi
done <<< "$EXPECTED_EVENT_TYPES"

UNKNOWN_FRONTEND_EVENT_TYPES="$(set_difference "$FRONTEND_EVENT_TYPES" "$EXPECTED_EVENT_TYPES")"

if [[ -n "$UNKNOWN_FRONTEND_EVENT_TYPES" ]]; then
  fail "frontend harness references unknown widget event types:"
  echo "$UNKNOWN_FRONTEND_EVENT_TYPES"
fi

if ! file_contains_literal "CANONICAL_WIDGET_EVENT_TYPES.includes(eventEnvelope.type)" "$BRIDGE_FILE"; then
  fail "JS bridge missing canonical widget event type membership guard"
fi

if ! file_contains_literal "transport.invalid_widget_event_type" "$BRIDGE_FILE"; then
  fail "JS bridge missing typed invalid widget event type error code"
fi

if [[ "$failures" -ne 0 ]]; then
  echo
  echo "Frontend widget event catalog contract validation failed."
  exit 1
fi

echo "Frontend widget event catalog contract validation passed."
