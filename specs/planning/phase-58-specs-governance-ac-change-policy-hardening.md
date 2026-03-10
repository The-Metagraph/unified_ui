# Phase 58 - Specs Governance AC Change-Policy Hardening

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `scripts/validate_specs_governance.sh`
- `specs/conformance/spec_conformance_matrix.md`
- `specs/operations/rfc_intake_governance.md`
- `test/web_ui/integration/phase_58_specs_governance_change_policy_test.exs`
- `test/web_ui/integration/phase_14_release_gate_regression_test.exs`

## Relevant Assumptions / Defaults
- AC-bearing component specs now live outside legacy `specs/core|infrastructure|services|session` directories.
- Governance change-policy coupling MUST still fail closed when AC-bearing component docs change without required contract/matrix updates.
- Regression coverage SHOULD validate both fail and pass paths for change-policy detection.

[x] 58 Phase 58 - Specs Governance AC Change-Policy Hardening
  Restore AC-bearing component change detection against current specs paths and lock fail-closed behavior with regression tests.

  [x] 58.1 Section - Governance Path Detection Fix
    Update specs-governance change-policy detection to evaluate changed component markdown under the current specs layout.

    [x] 58.1.1 Task - Replace legacy component path filter in governance validator
      Ensure changed markdown files under `specs/` are considered and then filtered to AC-bearing component specs.

      [x] 58.1.1.1 Subtask - Expand component markdown change regex to current `specs/*.md` coverage.
      [x] 58.1.1.2 Subtask - Preserve AC-bearing filtering by existing `COMPONENT_SPECS` detection.
      [x] 58.1.1.3 Subtask - Preserve existing fail-closed diagnostics for missing contract/matrix coupling.

  [x] 58.2 Section - Change-Policy Regression Coverage
    Add deterministic integration coverage for AC-bearing change-policy fail and pass probes.

    [x] 58.2.1 Task - Add governance change-policy regression integration tests
      Verify AC-bearing component changes fail without coupled contract/matrix updates and non-AC conformance-doc changes pass.

      [x] 58.2.1.1 Subtask - Add temp-worktree probe asserting fail-closed diagnostics for AC-bearing component-only changes.
      [x] 58.2.1.2 Subtask - Add temp-worktree probe asserting non-AC conformance doc edits do not trigger AC-coupling failures.
      [x] 58.2.1.3 Subtask - Tag regression tests as conformance and keep deterministic output assertions.

  [x] 58.3 Section - Planning Index Alignment
    Keep planning index synchronized with governance hardening phase coverage.

    [x] 58.3.1 Task - Add phase entry in planning index
      Register Phase 58 in planning README with concise scope summary and link.

      [x] 58.3.1.1 Subtask - Add ordered phase-list item for AC change-policy hardening.
      [x] 58.3.1.2 Subtask - Preserve phase numbering continuity.
      [x] 58.3.1.3 Subtask - Align wording with governance validator and regression intent.

  [x] 58.4 Section - Phase 58 Integration Tests
    Validate governance hardening behavior with deterministic script and conformance checks.

    [x] 58.4.1 Task - Governance and conformance validation continuity
      Verify updated governance path detection and regression tests preserve deterministic release-readiness behavior.

      [x] 58.4.1.1 Subtask - Verify `mix test test/web_ui/integration/phase_58_specs_governance_change_policy_test.exs` passes.
      [x] 58.4.1.2 Subtask - Verify `./scripts/validate_specs_governance.sh` passes in workspace with expected changes.
      [x] 58.4.1.3 Subtask - Verify `./scripts/run_release_readiness.sh --report-only` remains green.
