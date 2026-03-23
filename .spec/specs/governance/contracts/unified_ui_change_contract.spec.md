# Unified UI Change Contract

This contract defines how the authored `unified_ui` package design specs are governed in the centralized root `.spec` workspace.

```spec-meta
id: repo.governance.unified_ui_contract
kind: contract
status: active
summary: Governance contract for the canonical `unified_ui` DSL package design subjects.
surface:
  - packages/unified-ui
  - .spec/specs/unified-ui/**/*.spec.md
decisions:
  - repo.governance.contract_policy
  - repo.governance.package_contract_policy
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: repo.governance.unified_ui_specs_updated_with_surface_changes
  statement: Changes to the canonical `unified_ui` authored DSL surface for widgets, layouts, layering, styling, theming, or interaction binding shall update the affected authored subjects under `.spec/specs/unified-ui/` in the same change set.
  priority: must
  stability: stable

- id: repo.governance.unified_ui_stays_within_ecosystem_bounds
  statement: The `unified_ui` package design subjects shall not define a broader canonical rendering surface or runtime responsibility than the root ecosystem subjects under `.spec/specs/` allow.
  priority: must
  stability: stable

- id: repo.governance.unified_ui_moves_with_unified_iur
  statement: Changes to the canonical `unified_ui` widget, display-system, or theming surface intended for ecosystem-wide authoring shall update the corresponding authored subjects under `.spec/specs/unified-iur/` in the same change set.
  priority: must
  stability: stable

- id: repo.governance.unified_ui_not_runtime_contract
  statement: The `unified_ui` package design subjects shall govern the authored DSL package and shall not absorb runtime-library-native responsibilities owned by `live_ui`, `elm_ui`, or `desktop_ui`.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/governance/contracts/unified_ui_change_contract.spec.md
  covers:
    - repo.governance.unified_ui_specs_updated_with_surface_changes
    - repo.governance.unified_ui_stays_within_ecosystem_bounds
    - repo.governance.unified_ui_moves_with_unified_iur
    - repo.governance.unified_ui_not_runtime_contract
```
