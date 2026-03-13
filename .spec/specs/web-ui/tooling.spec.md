# WebUi Tooling

This subject backfills the current operational tooling and validation-gate
contract implemented by `packages/web_ui`.

```spec-meta
id: web_ui.tooling
kind: tooling
status: active
summary: Current tooling contract for `packages/web_ui`, including conformance automation, RFC or specs governance validation and generation, release-readiness gating, and frontend parity validation wiring in local hooks and CI.
surface:
  - packages/web_ui/scripts
  - packages/web_ui/.githooks
  - packages/web_ui/.github/workflows
  - packages/web_ui/rfcs
  - packages/web_ui/specs/conformance
  - packages/web_ui/test/web_ui/integration
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: web_ui.tooling.conformance_harness
  statement: 'The package shall expose the current conformance harness that checks scenario-catalog and matrix alignment, supports report-only execution, and runs deterministic conformance-tagged tests when alignment passes.'
  priority: must
  stability: stable

- id: web_ui.tooling.governance_automation
  statement: 'The package shall expose the current RFC and specs governance automation for validating RFC metadata and mappings, generating governance-compliant spec stubs from RFC plans, and enforcing AC-bearing change coupling rules.'
  priority: must
  stability: stable

- id: web_ui.tooling.release_and_frontend_gates
  statement: 'The package shall keep the current release-readiness and frontend-parity gate stack wired through shell scripts, git hooks, and CI workflows for frontend toolchain validation and the implemented frontend contract validators.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/web_ui/scripts/run_conformance.sh
  covers:
    - web_ui.tooling.conformance_harness

- kind: source_file
  target: packages/web_ui/scripts/validate_rfc_governance.sh
  covers:
    - web_ui.tooling.governance_automation

- kind: source_file
  target: packages/web_ui/scripts/gen_specs_from_rfc.sh
  covers:
    - web_ui.tooling.governance_automation

- kind: source_file
  target: packages/web_ui/scripts/validate_specs_governance.sh
  covers:
    - web_ui.tooling.governance_automation

- kind: source_file
  target: packages/web_ui/scripts/run_release_readiness.sh
  covers:
    - web_ui.tooling.release_and_frontend_gates

- kind: source_file
  target: packages/web_ui/.githooks/pre-commit
  covers:
    - web_ui.tooling.release_and_frontend_gates

- kind: source_file
  target: packages/web_ui/.githooks/pre-push
  covers:
    - web_ui.tooling.release_and_frontend_gates

- kind: source_file
  target: packages/web_ui/.github/workflows/frontend-toolchain.yml
  covers:
    - web_ui.tooling.release_and_frontend_gates

- kind: source_file
  target: packages/web_ui/.github/workflows/conformance.yml
  covers:
    - web_ui.tooling.conformance_harness

- kind: source_file
  target: packages/web_ui/.github/workflows/rfc-governance.yml
  covers:
    - web_ui.tooling.governance_automation

- kind: source_file
  target: packages/web_ui/.github/workflows/specs-governance.yml
  covers:
    - web_ui.tooling.governance_automation

- kind: source_file
  target: packages/web_ui/.github/workflows/release-readiness.yml
  covers:
    - web_ui.tooling.release_and_frontend_gates

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_08_conformance_automation_test.exs
  covers:
    - web_ui.tooling.conformance_harness

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_09_rfc_governance_operations_test.exs
  covers:
    - web_ui.tooling.governance_automation

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_10_first_slice_release_readiness_test.exs
  covers:
    - web_ui.tooling.release_and_frontend_gates

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_34_frontend_toolchain_enforcement_test.exs
  covers:
    - web_ui.tooling.release_and_frontend_gates

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_36_frontend_transport_contract_parity_test.exs
  covers:
    - web_ui.tooling.release_and_frontend_gates

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_37_frontend_cloudevent_contract_parity_test.exs
  covers:
    - web_ui.tooling.release_and_frontend_gates

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_39_frontend_event_catalog_parity_test.exs
  covers:
    - web_ui.tooling.release_and_frontend_gates

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_58_specs_governance_change_policy_test.exs
  covers:
    - web_ui.tooling.governance_automation
```
