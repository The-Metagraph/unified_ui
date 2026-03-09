#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

NAMING_FILE="lib/web_ui/transport/naming.ex"
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

extract_default_topic() {
  sed -n 's/^  @default_topic "\(.*\)"/\1/p' "$NAMING_FILE"
}

extract_events() {
  local event_block="$1"

  awk -v block="$event_block" '
    $0 ~ "@" block " \\[" { in_block = 1; next }
    in_block && $0 ~ /]/ { in_block = 0 }
    in_block {
      while (match($0, /"[^"]+"/)) {
        event_name = substr($0, RSTART + 1, RLENGTH - 2)
        print event_name
        $0 = substr($0, RSTART + RLENGTH)
      }
    }
  ' "$NAMING_FILE"
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

require_file "$NAMING_FILE"
require_file "$ELM_FILE"
require_file "$BRIDGE_FILE"

DEFAULT_TOPIC="$(extract_default_topic)"

if [[ -z "$DEFAULT_TOPIC" ]]; then
  echo "ERROR: unable to extract default topic from $NAMING_FILE"
  exit 1
fi

CLIENT_EVENTS="$(extract_events client_events | sort -u)"
SERVER_EVENTS="$(extract_events server_events | sort -u)"
EXPECTED_EVENTS="$(printf "%s\n%s\n" "$CLIENT_EVENTS" "$SERVER_EVENTS" | sed '/^$/d' | sort -u)"
FRONTEND_EVENTS="$(rg -o --no-filename 'runtime\.event\.[a-z_]+\.(v[0-9]+)' "$ELM_FILE" "$BRIDGE_FILE" | sort -u || true)"

echo "Validating frontend transport contract parity..."

while IFS= read -r event_name; do
  [[ -z "$event_name" ]] && continue

  if ! rg -Fq -- "$event_name" "$ELM_FILE"; then
    fail "Elm runtime missing canonical event name '$event_name'"
  fi

  if ! rg -Fq -- "$event_name" "$BRIDGE_FILE"; then
    fail "JS bridge missing canonical event name '$event_name'"
  fi
done <<< "$EXPECTED_EVENTS"

UNKNOWN_FRONTEND_EVENTS="$(set_difference "$FRONTEND_EVENTS" "$EXPECTED_EVENTS")"

if [[ -n "$UNKNOWN_FRONTEND_EVENTS" ]]; then
  fail "frontend references unknown transport event names:"
  echo "$UNKNOWN_FRONTEND_EVENTS"
fi

if ! rg -Fq -- "$DEFAULT_TOPIC" "$ELM_FILE"; then
  fail "Elm runtime missing canonical default topic '$DEFAULT_TOPIC'"
fi

if ! rg -Fq -- "$DEFAULT_TOPIC" "$BRIDGE_FILE"; then
  fail "JS bridge missing canonical default topic '$DEFAULT_TOPIC'"
fi

if [[ "$failures" -ne 0 ]]; then
  echo
  echo "Frontend transport contract validation failed."
  exit 1
fi

echo "Frontend transport contract validation passed."
