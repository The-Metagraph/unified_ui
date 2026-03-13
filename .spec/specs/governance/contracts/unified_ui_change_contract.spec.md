# UnifiedUi Change Contract

This contract defines how changes to `packages/unified-ui` and its backfilled
package subjects are governed in the centralized root `.spec` workspace.

```spec-meta
id: repo.governance.unified_ui_contract
kind: contract
status: active
summary: Governance contract for the current `unified-ui` DSL, widgets, runtime, adapters, and tooling backfill.
surface:
  - packages/unified-ui
  - .spec/specs/unified-ui
decisions:
  - repo.governance.contract_policy
  - repo.governance.package_contract_policy
```

## Requirements

```spec-requirements
- id: repo.governance.unified_ui_specs_updated_with_surface_changes
  statement: Changes to the current `unified-ui` DSL, widget entities, runtime, adapters, or package tooling shall update the affected authored subjects under `.spec/specs/unified-ui/` in the same change set.
  priority: must
  stability: stable

- id: repo.governance.unified_ui_backfill_stays_package_local
  statement: The `unified-ui` package backfill shall remain grounded in current `packages/unified-ui` code and tests and shall not act as a substitute for ecosystem-level DSL or IUR governance owned under `.spec/specs/ecosystem/`.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/governance/contracts/unified_ui_change_contract.spec.md
  covers:
    - repo.governance.unified_ui_specs_updated_with_surface_changes
    - repo.governance.unified_ui_backfill_stays_package_local
```
