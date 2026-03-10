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

extract_event_types() {
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

extract_required_payload_keys() {
  awk '
    /required_all_of:|required_any_of:/ {
      line = $0
      while (match(line, /"[^"]+"/)) {
        key = substr(line, RSTART + 1, RLENGTH - 2)
        print key
        line = substr(line, RSTART + RLENGTH)
      }
    }
  ' "$EVENT_CATALOG_FILE" | sort -u
}

require_file "$EVENT_CATALOG_FILE"
require_file "$ELM_FILE"
require_file "$BRIDGE_FILE"

EVENT_TYPES="$(extract_event_types)"
REQUIRED_PAYLOAD_KEYS="$(extract_required_payload_keys)"

if [[ -z "$EVENT_TYPES" ]]; then
  echo "ERROR: unable to extract canonical widget event types from $EVENT_CATALOG_FILE"
  exit 1
fi

if [[ -z "$REQUIRED_PAYLOAD_KEYS" ]]; then
  echo "ERROR: unable to extract canonical required payload keys from $EVENT_CATALOG_FILE"
  exit 1
fi

echo "Validating frontend widget event payload contract parity..."

while IFS= read -r event_type; do
  [[ -z "$event_type" ]] && continue

  if ! file_contains_literal "\"$event_type\": { required_all_of:" "$BRIDGE_FILE"; then
    fail "JS bridge missing canonical payload-key spec for event type '$event_type'"
  fi
done <<< "$EVENT_TYPES"

while IFS= read -r key; do
  [[ -z "$key" ]] && continue

  if ! file_contains_literal "\"$key\"" "$ELM_FILE"; then
    fail "Elm harness missing canonical widget payload key '$key'"
  fi

  if ! file_contains_literal "\"$key\"" "$BRIDGE_FILE"; then
    fail "JS bridge missing canonical widget payload key '$key'"
  fi
done <<< "$REQUIRED_PAYLOAD_KEYS"

if ! file_contains_literal "defaultWidgetEventRequiredAllOf" "$ELM_FILE"; then
  fail "Elm harness missing explicit required payload key contract helper"
fi

if ! file_contains_literal "CANONICAL_WIDGET_EVENT_KEY_SPECS" "$BRIDGE_FILE"; then
  fail "JS bridge missing canonical widget payload-key spec map"
fi

if ! file_contains_literal "validateWidgetEventPayload" "$BRIDGE_FILE"; then
  fail "JS bridge missing widget payload validation helper"
fi

if ! file_contains_literal "transport.invalid_widget_event_payload" "$BRIDGE_FILE"; then
  fail "JS bridge missing typed invalid widget payload error code"
fi

if [[ "$failures" -ne 0 ]]; then
  echo
  echo "Frontend widget event payload contract validation failed."
  exit 1
fi

echo "Frontend widget event payload contract validation passed."
