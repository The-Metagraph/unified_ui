#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

export MIX_ENV="${MIX_ENV:-test}"

SCENARIO_CATALOG="specs/conformance/scenario_catalog.md"
SPEC_CONFORMANCE_MATRIX="specs/conformance/spec_conformance_matrix.md"
CONFORMANCE_TEST_ROOT="test"

REPORT_ONLY=0
SKIP_GOVERNANCE=0

for arg in "$@"; do
  case "$arg" in
    --report-only) REPORT_ONLY=1 ;;
    --skip-governance) SKIP_GOVERNANCE=1 ;;
    *)
      echo "Unknown argument: $arg"
      echo "Usage: ./scripts/run_conformance.sh [--report-only] [--skip-governance]"
      exit 1
      ;;
  esac
done

read_scenarios() {
  local target="$1"
  if [[ -e "$target" ]]; then
    rg -o --no-filename 'SCN-[0-9]+' "$target" | sort -u || true
  fi
}

set_difference() {
  local left="$1"
  local right="$2"

  while IFS= read -r id; do
    [[ -z "$id" ]] && continue
    if ! echo "$right" | grep -Fxq "$id"; then
      echo "$id"
    fi
  done <<< "$left"
}

summarize_id_locations() {
  local id="$1"
  local target="$2"
  rg -n "$id" "$target" || true
}

if [[ "$SKIP_GOVERNANCE" -eq 0 ]]; then
  ./scripts/validate_specs_governance.sh
fi

echo "== Conformance Scenario Discovery =="

CATALOG_SCENARIOS="$(read_scenarios "$SCENARIO_CATALOG")"
MATRIX_SCENARIOS="$(read_scenarios "$SPEC_CONFORMANCE_MATRIX")"
TEST_SCENARIOS="$(read_scenarios "$CONFORMANCE_TEST_ROOT")"

echo "Catalog scenarios: $(echo "$CATALOG_SCENARIOS" | sed '/^$/d' | wc -l | tr -d ' ')"
echo "Matrix scenarios:  $(echo "$MATRIX_SCENARIOS" | sed '/^$/d' | wc -l | tr -d ' ')"
echo "Test scenarios:    $(echo "$TEST_SCENARIOS" | sed '/^$/d' | wc -l | tr -d ' ')"

echo "Scenarios in catalog: ${CATALOG_SCENARIOS//$'\n'/, }"
echo "Scenarios in matrix:  ${MATRIX_SCENARIOS//$'\n'/, }"
echo "Scenarios in tests:   ${TEST_SCENARIOS//$'\n'/, }"

MISSING_FROM_CATALOG="$(set_difference "$MATRIX_SCENARIOS" "$CATALOG_SCENARIOS")"
MISSING_FROM_TESTS="$(set_difference "$MATRIX_SCENARIOS" "$TEST_SCENARIOS")"
ORPHAN_TEST_SCENARIOS="$(set_difference "$TEST_SCENARIOS" "$CATALOG_SCENARIOS")"

if [[ -n "$MISSING_FROM_CATALOG" ]]; then
  echo
  echo "FAIL: matrix scenarios missing from scenario catalog:"
  echo "$MISSING_FROM_CATALOG"

  while IFS= read -r id; do
    [[ -z "$id" ]] && continue
    echo "-- matrix references for $id --"
    summarize_id_locations "$id" "$SPEC_CONFORMANCE_MATRIX"
  done <<< "$MISSING_FROM_CATALOG"

  exit 1
fi

if [[ -n "$MISSING_FROM_TESTS" ]]; then
  echo
  echo "FAIL: matrix scenarios missing conformance tests:"
  echo "$MISSING_FROM_TESTS"

  while IFS= read -r id; do
    [[ -z "$id" ]] && continue
    echo "-- matrix references for $id --"
    summarize_id_locations "$id" "$SPEC_CONFORMANCE_MATRIX"
  done <<< "$MISSING_FROM_TESTS"

  exit 1
fi

if [[ -n "$ORPHAN_TEST_SCENARIOS" ]]; then
  echo
  echo "WARN: conformance tests reference scenarios missing from scenario catalog:"
  echo "$ORPHAN_TEST_SCENARIOS"
fi

echo "Scenario alignment checks passed."

if [[ "$REPORT_ONLY" -eq 1 ]]; then
  echo "Report-only mode enabled; skipping test execution."
  exit 0
fi

if rg -q '@(module)?tag[[:space:]]+:conformance' "$CONFORMANCE_TEST_ROOT" 2>/dev/null; then
  echo "== Running deterministic conformance suite =="
  mix test --only conformance --seed 0
else
  echo "INFO: no conformance-tagged tests found."
  echo "INFO: skipping mix test --only conformance (bootstrap mode)."
fi
