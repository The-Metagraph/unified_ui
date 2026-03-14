---
id: repo.governance.package_contract_policy
status: accepted
date: 2026-03-14
affects:
  - repo.package
  - repo.governance.unified_ui_contract
  - repo.governance.unified_iur_contract
---

# Package Design Specs Use Centralized Package Contracts

## Context

The root `.spec` workspace already has repository-wide governance contracts and
new package design specs for `unified_ui` and `unified_iur`. Those package
subjects describe intended package architecture, but they do not yet have
explicit package-scoped governance that says how those subjects must move when
the package contract changes.

## Decision

1. Package-specific governance for package design specs will remain centralized
   under `.spec/specs/governance/contracts/`.
2. Each governed package design spec set may have a dedicated package change
   contract scoped to the package directory and its authored subject directory.
3. Changes that affect a governed package's canonical package surface must
   update the affected package subjects in the same change set.
4. When a governed package participates in a bilateral canonical contract, its
   package change contract may require corresponding updates in the paired
   package subject set in the same change set.
5. Package governance contracts describe authored package intent and change
   policy; executable conformance remains a separate future layer.

## Consequences

- Package design specs gain explicit governance without creating separate
  package-local governance workspaces.
- Package-level intent remains machine-indexable in the root `.spec`
  workspace.
- Bilateral package contracts such as the `unified_ui` and `unified_iur`
  relationship can be governed explicitly rather than only by implication.
