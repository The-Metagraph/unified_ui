# Workspace Governance Contract

This contract defines the durable governance rules for authored subjects, ADR use, and repository-wide policy changes.

```spec-meta
id: repo.governance.contract
kind: contract
status: active
summary: Normative governance contract for authored subjects, ADR use, and durable repository-wide policy changes.
surface:
  - .spec/specs/**/*.spec.md
  - .spec/decisions/**/*.md
  - .spec/README.md
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: repo.governance.contract.subjects_canonical
  statement: Authored subjects under .spec/specs/**/*.spec.md shall remain the canonical current-truth contract for repository behavior and governance.
  priority: must
  stability: stable

- id: repo.governance.contract.adrs_for_cross_cutting
  statement: Durable cross-cutting governance changes shall add or update at least one ADR under .spec/decisions/ that records context, decision, and consequences.
  priority: must
  stability: stable

- id: repo.governance.contract.subjects_reference_decisions
  statement: A governance subject constrained by a durable ADR shall reference that decision id in spec-meta.decisions.
  priority: must
  stability: stable

- id: repo.governance.contract.no_inflight_proposal_layer
  statement: The .spec workspace shall not grow separate in-flight proposal or branch-local planning folders; Git history and pull requests remain the time dimension for change.
  priority: must
  stability: stable

- id: repo.governance.contract.conformance_not_embedded
  statement: Governance contracts shall define durable policy and authored obligations, while conformance evidence will be added later in a separate layer.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/governance/contracts/workspace_governance_contract.spec.md
  covers:
    - repo.governance.contract.adrs_for_cross_cutting
    - repo.governance.contract.no_inflight_proposal_layer
    - repo.governance.contract.subjects_canonical
    - repo.governance.contract.subjects_reference_decisions
    - repo.governance.contract.conformance_not_embedded
```
