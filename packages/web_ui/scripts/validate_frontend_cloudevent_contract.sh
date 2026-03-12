#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

CLOUDEVENT_FILE="lib/web_ui/cloud_event.ex"
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

extract_atom_list() {
  local attr="$1"

  awk -v attr="$attr" '
    $0 ~ "@" attr " \\[" { in_block = 1 }
    in_block {
      while (match($0, /:[a-z_]+/)) {
        atom = substr($0, RSTART + 1, RLENGTH - 1)
        print atom
        $0 = substr($0, RSTART + RLENGTH)
      }
      if ($0 ~ /]/) {
        in_block = 0
      }
    }
  ' "$CLOUDEVENT_FILE" | sort -u
}

require_file "$CLOUDEVENT_FILE"
require_file "$ELM_FILE"
require_file "$BRIDGE_FILE"

REQUIRED_FIELDS="$(extract_atom_list required_fields)"
REQUIRED_EXTENSIONS="$(extract_atom_list required_extensions)"

if [[ -z "$REQUIRED_FIELDS" ]]; then
  echo "ERROR: unable to extract @required_fields from $CLOUDEVENT_FILE"
  exit 1
fi

if [[ -z "$REQUIRED_EXTENSIONS" ]]; then
  echo "ERROR: unable to extract @required_extensions from $CLOUDEVENT_FILE"
  exit 1
fi

echo "Validating frontend CloudEvent contract parity..."

while IFS= read -r field; do
  [[ -z "$field" ]] && continue

  if ! file_contains_literal "\"$field\"" "$ELM_FILE"; then
    fail "Elm runtime missing required CloudEvent field '$field'"
  fi

  if ! file_contains_literal "\"$field\"" "$BRIDGE_FILE"; then
    fail "JS bridge missing required CloudEvent field '$field'"
  fi
done <<< "$REQUIRED_FIELDS"

while IFS= read -r extension; do
  [[ -z "$extension" ]] && continue

  if ! file_contains_literal "\"$extension\"" "$ELM_FILE"; then
    fail "Elm runtime missing required CloudEvent extension '$extension'"
  fi

  if ! file_contains_literal "\"$extension\"" "$BRIDGE_FILE"; then
    fail "JS bridge missing required CloudEvent extension '$extension'"
  fi
done <<< "$REQUIRED_EXTENSIONS"

if ! file_contains_literal "transport.invalid_cloudevent_envelope" "$BRIDGE_FILE"; then
  fail "JS bridge missing typed CloudEvent envelope validation error code"
fi

if [[ "$failures" -ne 0 ]]; then
  echo
  echo "Frontend CloudEvent contract validation failed."
  exit 1
fi

echo "Frontend CloudEvent contract validation passed."
