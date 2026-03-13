# UnifiedIUR Change Contract

This contract defines how changes to `packages/unified_iur` and its backfilled
package subjects are governed in the centralized root `.spec` workspace.

```spec-meta
id: repo.governance.unified_iur_contract
kind: contract
status: active
summary: Governance contract for the current `unified_iur` type surface, struct families, and composite-widget backfill.
surface:
  - packages/unified_iur
  - .spec/specs/unified-iur
decisions:
  - repo.governance.contract_policy
  - repo.governance.package_contract_policy
```

## Requirements

```spec-requirements
- id: repo.governance.unified_iur_specs_updated_with_surface_changes
  statement: Changes to the current `unified_iur` public types, widget or layout structs, style model, or composite-widget data structures shall update the affected authored subjects under `.spec/specs/unified-iur/` in the same change set.
  priority: must
  stability: stable

- id: repo.governance.unified_iur_backfill_stays_package_local
  statement: The `unified_iur` package backfill shall remain a current package-code contract and shall not imply DSL, compiler, or ecosystem-boundary guarantees unless those guarantees are implemented inside `packages/unified_iur` and reflected by the affected package subjects.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/governance/contracts/unified_iur_change_contract.spec.md
  covers:
    - repo.governance.unified_iur_specs_updated_with_surface_changes
    - repo.governance.unified_iur_backfill_stays_package_local
```
