#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
UNKNOWN_SCN_ID="${UNKNOWN_SCN_ID:-SCN-999}"
WORKTREE_PATH=""
failures=0

log_fail() {
  echo "FAIL: $1"
  failures=1
}

cleanup() {
  if [[ -n "$WORKTREE_PATH" ]] && [[ -d "$WORKTREE_PATH" ]]; then
    git -C "$ROOT" worktree remove --force "$WORKTREE_PATH" >/dev/null 2>&1 || true
  fi
}

run_release_gate_report_only() {
  local target_root="$1"
  local output status

  set +e
  output="$(cd "$target_root" && ./scripts/run_release_readiness.sh --report-only 2>&1)"
  status=$?
  set -e

  echo "$output"
  return "$status"
}

echo "== Release Gate Regression Checks =="

echo "[1/2] Clean-input probe (false-positive guard)"
set +e
clean_output="$(run_release_gate_report_only "$ROOT")"
clean_status=$?
set -e

if [[ "$clean_status" -ne 0 ]]; then
  log_fail "release gate should pass on clean inputs (status=$clean_status)"
fi

if ! echo "$clean_output" | grep -q 'RELEASE_GATE_RESULT=PASS'; then
  log_fail "clean-input probe missing RELEASE_GATE_RESULT=PASS marker"
fi

if ! echo "$clean_output" | grep -q 'RELEASE_GATE_STAGE=1_specs_governance:pass'; then
  log_fail "clean-input probe missing required stage-pass marker"
fi

echo "[2/2] Injected-defect probe (false-negative guard)"
WORKTREE_PATH="$(mktemp -d "${TMPDIR:-/tmp}/web_ui_release_gate_probe_XXXXXX")"
git -C "$ROOT" worktree add --detach "$WORKTREE_PATH" HEAD >/dev/null

trap cleanup EXIT

MATRIX_PATH="$WORKTREE_PATH/specs/conformance/spec_conformance_matrix.md"

if [[ ! -f "$MATRIX_PATH" ]]; then
  log_fail "missing matrix file in temporary worktree"
else
  UNKNOWN_SCN_ID="$UNKNOWN_SCN_ID" perl -0pi -e '
    my $id = $ENV{UNKNOWN_SCN_ID};
    my $from = q{| `specs/operations/rfc_intake_governance.md` | `AC-*` | `REQ-CP-*`, `REQ-OBS-*` | `SCN-001`, `SCN-006` |};
    my $to = "| `specs/operations/rfc_intake_governance.md` | `AC-*` | `REQ-CP-*`, `REQ-OBS-*` | `SCN-001`, `SCN-006`, `$id` |";
    s/\Q$from\E/$to/g;
  ' "$MATRIX_PATH"

  set +e
  defect_output="$(run_release_gate_report_only "$WORKTREE_PATH")"
  defect_status=$?
  set -e

  if [[ "$defect_status" -eq 0 ]]; then
    log_fail "release gate should fail on injected unknown scenario (${UNKNOWN_SCN_ID})"
  fi

  if ! echo "$defect_output" | grep -q "${UNKNOWN_SCN_ID}"; then
    log_fail "injected-defect probe output missing unknown scenario id (${UNKNOWN_SCN_ID})"
  fi

  if ! echo "$defect_output" | grep -q "Governance validation failed"; then
    log_fail "injected-defect probe missing governance failure diagnostic"
  fi

  if echo "$defect_output" | grep -q 'RELEASE_GATE_RESULT=PASS'; then
    log_fail "injected-defect probe should not emit pass marker"
  fi
fi

cleanup
trap - EXIT

if [[ "$failures" -ne 0 ]]; then
  echo
  echo "Release gate regression checks failed."
  exit 1
fi

echo "Release gate regression checks passed."
