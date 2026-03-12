#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

RUNTIME_CONTEXT_FILE="lib/web_ui/runtime_context.ex"
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
  ' "$RUNTIME_CONTEXT_FILE" | sort -u
}

require_file "$RUNTIME_CONTEXT_FILE"
require_file "$ELM_FILE"
require_file "$BRIDGE_FILE"

REQUIRED_FIELDS="$(extract_atom_list required_fields)"
OPTIONAL_FIELDS="$(extract_atom_list optional_fields)"

if [[ -z "$REQUIRED_FIELDS" ]]; then
  echo "ERROR: unable to extract @required_fields from $RUNTIME_CONTEXT_FILE"
  exit 1
fi

if [[ -z "$OPTIONAL_FIELDS" ]]; then
  echo "ERROR: unable to extract @optional_fields from $RUNTIME_CONTEXT_FILE"
  exit 1
fi

echo "Validating frontend runtime-context contract parity..."

while IFS= read -r field; do
  [[ -z "$field" ]] && continue

  if ! file_contains_literal "\"$field\"" "$ELM_FILE"; then
    fail "Elm harness missing required runtime-context field '$field'"
  fi

  if ! file_contains_literal "\"$field\"" "$BRIDGE_FILE"; then
    fail "JS bridge missing required runtime-context field '$field'"
  fi
done <<< "$REQUIRED_FIELDS"

while IFS= read -r field; do
  [[ -z "$field" ]] && continue

  if ! file_contains_literal "\"$field\"" "$ELM_FILE"; then
    fail "Elm harness missing optional runtime-context field '$field'"
  fi

  if ! file_contains_literal "\"$field\"" "$BRIDGE_FILE"; then
    fail "JS bridge missing optional runtime-context field '$field'"
  fi
done <<< "$OPTIONAL_FIELDS"

if ! file_contains_literal "normalizeRuntimeContext" "$BRIDGE_FILE"; then
  fail "JS bridge missing runtime-context normalization helper"
fi

if ! file_contains_literal "context: runtimeContext" "$BRIDGE_FILE"; then
  fail "JS bridge missing runtime-context continuity payload wiring"
fi

if [[ "$failures" -ne 0 ]]; then
  echo
  echo "Frontend runtime-context contract validation failed."
  exit 1
fi

echo "Frontend runtime-context contract validation passed."
