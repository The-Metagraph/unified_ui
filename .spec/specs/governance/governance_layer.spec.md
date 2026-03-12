# Governance Layer

This subject defines the repository-wide governance layer for the root `.spec` workspace.

```spec-meta
id: repo.governance
kind: governance
status: active
summary: Repository-wide governance layer for durable contracts, ADR-backed policy, and future separation from conformance.
surface:
  - .spec/specs/governance/**/*.spec.md
  - .spec/decisions/**/*.md
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: repo.governance.contracts_authored
  statement: Durable governance rules shall be authored as Spec Led subjects under .spec/specs/governance/.
  priority: must
  stability: stable

- id: repo.governance.adrs_record_rationale
  statement: Cross-cutting governance rationale shall be recorded as ADRs under .spec/decisions/.
  priority: must
  stability: stable

- id: repo.governance.current_truth_only
  statement: Governance artifacts shall capture current enforced policy rather than proposal backlogs or branch-local implementation notes.
  priority: must
  stability: stable

- id: repo.governance.conformance_separate
  statement: Conformance shall be introduced as a separate future layer rather than embedded inside governance contracts.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/governance/governance_layer.spec.md
  covers:
    - repo.governance.contracts_authored
    - repo.governance.adrs_record_rationale
    - repo.governance.current_truth_only
    - repo.governance.conformance_separate
```
