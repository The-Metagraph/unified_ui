---
id: repo.governance.package_contract_policy
status: accepted
date: 2026-03-13
affects:
  - repo.package
  - repo.governance.desktop_ui_contract
  - repo.governance.live_ui_contract
  - repo.governance.unified_iur_contract
  - repo.governance.unified_ui_contract
  - repo.governance.web_ui_contract
---

# Package Governance Stays Centralized Through Package Contracts

## Context

The root `.spec` workspace already has repository-wide governance contracts and
package backfill subjects, but it does not yet give each package an explicit
governance contract. We want package-specific governance without breaking the
existing rule that governance remains centralized in the root governance layer.

## Decision

1. Package-specific governance will be authored as centralized contract subjects
   under `.spec/specs/governance/contracts/`, not as separate governance
   workspaces inside each package spec directory.
2. Each current package in `packages/` will have a dedicated governance
   contract scoped to its backfilled subject directory and current source
   surface.
3. Package governance contracts will require affected package specs to be
   updated in the same change set as package-surface changes.
4. Package governance contracts will continue to describe current package truth
   rather than acting as substitutes for ecosystem-level architecture or future
   conformance layers.

## Consequences

- Package backfills gain explicit governance while governance remains
  centralized in the root `.spec` workspace.
- Future package changes have a durable, machine-indexable contract about when
  package specs must move with code or documentation changes.
- Package governance stays distinct from ecosystem governance and from future
  conformance evidence.
