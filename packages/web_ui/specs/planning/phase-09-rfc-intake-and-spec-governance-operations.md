# Phase 9 - RFC Intake and Spec Governance Operations

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `rfcs/templates/rfc-template.md`
- `rfcs/index.md`
- `scripts/validate_rfc_governance.sh`
- `scripts/gen_specs_from_rfc.sh`
- `scripts/validate_specs_governance.sh`

## Relevant Assumptions / Defaults
- Material architecture/spec changes should start with RFC intake.
- RFC governance references must resolve to existing REQ/SCN/contract sources.
- Accepted/implemented RFCs require same-change-set specs updates.

[x] 9 Phase 9 - RFC Intake and Spec Governance Operations
  Implement an operational RFC workflow that is tightly coupled to specs governance and deterministic spec-surface generation.

  [x] 9.1 Section - RFC Authoring and Lifecycle Workflow
    Implement a repeatable RFC authoring process with metadata, mapping, and lifecycle hygiene.

    [x] 9.1.1 Task - Implement RFC intake authoring standards
      Ensure every RFC includes complete metadata, governance mapping, and creation plan entries.

      [x] 9.1.1.1 Subtask - Implement author guidance for RFC metadata and status transitions.
      [x] 9.1.1.2 Subtask - Implement mapping guidance for REQ family, SCN coverage, and contracts.
      [x] 9.1.1.3 Subtask - Implement plan-row guidance for create/update/deprecate actions.

    [x] 9.1.2 Task - Implement RFC registry and lifecycle hygiene
      Keep RFC index registration and lifecycle status transitions synchronized.

      [x] 9.1.2.1 Subtask - Implement RFC index update checks for new RFC IDs.
      [x] 9.1.2.2 Subtask - Implement status transition review checklist for PRs.
      [x] 9.1.2.3 Subtask - Implement supersede and deprecation tracking conventions.

  [x] 9.2 Section - Governance Validator and Generator Operations
    Implement robust operation of RFC validators and spec-generator workflows.

    [x] 9.2.1 Task - Implement strict RFC governance validation in local and CI flows
      Enforce metadata, mapping, and change-set coupling rules with deterministic diagnostics.

      [x] 9.2.1.1 Subtask - Implement pre-commit validation integration for RFC governance checks.
      [x] 9.2.1.2 Subtask - Implement CI workflow enforcement for RFC governance validation.
      [x] 9.2.1.3 Subtask - Implement failure diagnostics for unknown REQ/SCN/contract references.

    [x] 9.2.2 Task - Implement deterministic spec generation from approved RFC plans
      Use RFC plan rows to create consistent initial spec stubs for new component surfaces.

      [x] 9.2.2.1 Subtask - Implement generation preview workflows using `--dry-run`.
      [x] 9.2.2.2 Subtask - Implement overwrite and safety behavior for existing target files.
      [x] 9.2.2.3 Subtask - Implement generated stub verification for required governance sections.

  [x] 9.3 Section - Operational Runbooks and Governance Adoption
    Implement team-facing operational guidance for RFC + specs governance workflows.

    [x] 9.3.1 Task - Implement governance runbook updates
      Document reviewer and author workflows for RFC/spec governance alignment.

      [x] 9.3.1.1 Subtask - Implement reviewer checklist for RFC governance mapping quality.
      [x] 9.3.1.2 Subtask - Implement author checklist for matrix and contract synchronization.
      [x] 9.3.1.3 Subtask - Implement incident guidance for validator false positives/negatives.

    [x] 9.3.2 Task - Implement adoption tracking and governance debt triage
      Track missing governance artifacts and prioritize remediation.

      [x] 9.3.2.1 Subtask - Implement periodic scan for orphaned or stale RFC references.
      [x] 9.3.2.2 Subtask - Implement governance debt issue templates with ownership tags.
      [x] 9.3.2.3 Subtask - Implement cadence for governance baseline review.

  [x] 9.4 Section - Phase 9 Integration Tests
    Validate RFC governance workflows, validator behavior, and generation paths end-to-end.

    [x] 9.4.1 Task - RFC validator integration scenarios
      Verify pass/fail outcomes for valid and invalid RFC documents.

      [x] 9.4.1.1 Subtask - Verify invalid metadata/missing sections fail with explicit diagnostics.
      [x] 9.4.1.2 Subtask - Verify unknown REQ/SCN/contract references fail deterministically.
      [x] 9.4.1.3 Subtask - Verify accepted RFC changes without specs deltas fail gate checks.

    [x] 9.4.2 Task - RFC generation integration scenarios
      Verify generator behavior for dry-run, create, skip, and overwrite paths.

      [x] 9.4.2.1 Subtask - Verify dry-run output matches expected target file plan rows.
      [x] 9.4.2.2 Subtask - Verify create rows produce compliant spec stubs.
      [x] 9.4.2.3 Subtask - Verify existing-file skip/overwrite behavior remains deterministic.
