# Ecosystem Change Contract

This contract defines how ecosystem-level architectural changes are governed locally in the root `.spec` workspace.

```spec-meta
id: repo.governance.ecosystem_contract
kind: contract
status: active
summary: Governance contract for changes to package responsibilities, DSL and IUR boundaries, and cross-package signal transport.
surface:
  - .spec/specs/ecosystem/**/*.spec.md
  - .spec/decisions/architecture/**/*.md
decisions:
  - repo.governance.contract_policy
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: repo.governance.ecosystem_specs_updated_with_boundary_changes
  statement: Changes to package responsibilities, DSL and IUR mapping, or signal transport shall update the affected ecosystem subject specs in the same change set.
  priority: must
  stability: stable

- id: repo.governance.ecosystem_decision_recorded
  statement: Durable ecosystem architecture changes shall add or revise an ADR under .spec/decisions/architecture/.
  priority: must
  stability: stable

- id: repo.governance.ecosystem_governance_precedes_conformance
  statement: Governance contracts may define required ecosystem invariants before executable conformance artifacts are introduced, but they shall not imply conformance coverage exists before the dedicated conformance layer is authored.
  priority: must
  stability: stable

- id: repo.governance.ecosystem_renderer_boundary_preserved
  statement: Governance changes shall preserve the distinction between authored DSL semantics, canonical IUR, and native widget-library implementations unless an ADR explicitly redefines that boundary.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/governance/contracts/ecosystem_change_contract.spec.md
  covers:
    - repo.governance.ecosystem_specs_updated_with_boundary_changes
    - repo.governance.ecosystem_decision_recorded
    - repo.governance.ecosystem_governance_precedes_conformance
    - repo.governance.ecosystem_renderer_boundary_preserved
```
