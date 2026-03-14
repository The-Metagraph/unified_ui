# Unified IUR Change Contract

This contract defines how the authored `unified_iur` package design specs are governed in the centralized root `.spec` workspace.

```spec-meta
id: repo.governance.unified_iur_contract
kind: contract
status: active
summary: Governance contract for the canonical `unified_iur` interchange package design subjects.
surface:
  - packages/unified_iur
  - .spec/specs/unified-iur/**/*.spec.md
decisions:
  - repo.governance.contract_policy
  - repo.governance.package_contract_policy
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: repo.governance.unified_iur_specs_updated_with_surface_changes
  statement: Changes to the canonical `unified_iur` interchange surface for widgets, layouts, layering, styling, theming, or interaction representation shall update the affected authored subjects under `.spec/specs/unified-iur/` in the same change set.
  priority: must
  stability: stable

- id: repo.governance.unified_iur_stays_within_ecosystem_bounds
  statement: The `unified_iur` package design subjects shall not define a broader canonical interchange surface or runtime responsibility than the root ecosystem subjects under `.spec/specs/` allow.
  priority: must
  stability: stable

- id: repo.governance.unified_iur_moves_with_unified_ui
  statement: Changes to the canonical `unified_iur` widget, display-system, or theming surface intended for ecosystem-wide authoring and rendering shall update the corresponding authored subjects under `.spec/specs/unified-ui/` in the same change set.
  priority: must
  stability: stable

- id: repo.governance.unified_iur_not_runtime_contract
  statement: The `unified_iur` package design subjects shall govern the canonical interchange model and shall not absorb runtime-library-native widget or local signal responsibilities owned by `live_ui`, `web_ui`, or `desktop_ui`.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/governance/contracts/unified_iur_change_contract.spec.md
  covers:
    - repo.governance.unified_iur_specs_updated_with_surface_changes
    - repo.governance.unified_iur_stays_within_ecosystem_bounds
    - repo.governance.unified_iur_moves_with_unified_ui
    - repo.governance.unified_iur_not_runtime_contract
```
