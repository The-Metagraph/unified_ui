#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

WIDGET_REGISTRY_FILE="lib/web_ui/widget_registry.ex"
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

require_file "$WIDGET_REGISTRY_FILE"
require_file "$EVENT_CATALOG_FILE"
require_file "$ELM_FILE"
require_file "$BRIDGE_FILE"

ROUTE_FAMILIES="$(extract_route_families)"
ROUTE_KEYS="$(extract_route_keys)"
EVENT_ROUTE_PAIRS="$(extract_event_route_pairs)"

if [[ -z "$ROUTE_FAMILIES" ]]; then
  echo "ERROR: unable to extract canonical route families from $WIDGET_REGISTRY_FILE"
  exit 1
fi

if [[ -z "$ROUTE_KEYS" ]]; then
  echo "ERROR: unable to extract canonical route keys from $WIDGET_REGISTRY_FILE"
  exit 1
fi

if [[ -z "$EVENT_ROUTE_PAIRS" ]]; then
  echo "ERROR: unable to extract event route-family pairs from $EVENT_CATALOG_FILE"
  exit 1
fi

echo "Validating frontend widget event route contract parity..."

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

while IFS='|' read -r event_type route_family; do
  [[ -z "$event_type" || -z "$route_family" ]] && continue

  if ! file_contains_literal "\"$event_type\": \"$route_family\"" "$BRIDGE_FILE"; then
    fail "JS bridge missing canonical route family mapping '$event_type -> $route_family'"
  fi
done <<< "$EVENT_ROUTE_PAIRS"

if ! file_contains_literal "canonicalRouteKeyRequirements" "$ELM_FILE"; then
  fail "Elm harness missing canonical route key requirements helper"
fi

if ! file_contains_literal "defaultWidgetEventRouteFamily" "$ELM_FILE"; then
  fail "Elm harness missing default route family helper"
fi

if ! file_contains_literal "CANONICAL_WIDGET_EVENT_ROUTE_FAMILIES" "$BRIDGE_FILE"; then
  fail "JS bridge missing canonical event route-family map"
fi

if ! file_contains_literal "CANONICAL_ROUTE_KEY_REQUIREMENTS" "$BRIDGE_FILE"; then
  fail "JS bridge missing canonical route key requirements map"
fi

if ! file_contains_literal "validateWidgetEventRouteKeys" "$BRIDGE_FILE"; then
  fail "JS bridge missing route-key validation helper"
fi

if ! file_contains_literal "transport.invalid_widget_event_route" "$BRIDGE_FILE"; then
  fail "JS bridge missing typed invalid widget route error code"
fi

if [[ "$failures" -ne 0 ]]; then
  echo
  echo "Frontend widget event route contract validation failed."
  exit 1
fi

echo "Frontend widget event route contract validation passed."
