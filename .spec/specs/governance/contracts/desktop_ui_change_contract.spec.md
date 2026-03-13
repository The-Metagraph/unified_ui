# DesktopUi Change Contract

This contract defines how changes to `packages/desktop_ui` and its authored
ecosystem-aligned package subjects are governed in the centralized root `.spec`
workspace.

```spec-meta
id: repo.governance.desktop_ui_contract
kind: contract
status: active
summary: Governance contract for the ecosystem-aligned `desktop_ui` package subjects, including canonical IUR boundary, native desktop widget architecture, SDL2 runtime targets, and canonical signal transport.
surface:
  - packages/desktop_ui
  - .spec/specs/desktop-ui
decisions:
  - repo.governance.contract_policy
  - repo.governance.package_contract_policy
  - repo.desktop_ui.ecosystem_alignment
```

## Requirements

```spec-requirements
- id: repo.governance.desktop_ui_specs_updated_with_surface_changes
  statement: Changes to the `desktop_ui` package surface that affect its canonical UnifiedIUR boundary, native widget architecture, SDL2 runtime targets, or canonical signal transport shall update the affected authored subjects under `.spec/specs/desktop-ui/` in the same change set.
  priority: must
  stability: stable

- id: repo.governance.desktop_ui_specs_not_broader_than_ecosystem
  statement: Authored subjects under `.spec/specs/desktop-ui/` shall remain aligned with the ecosystem architecture, runtime, and signal transport decisions and shall not broaden the package contract with scaffold details, research notes, or proof-of-concept planning overlays unless those are first adopted into the root ecosystem or governance layer.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/governance/contracts/desktop_ui_change_contract.spec.md
  covers:
    - repo.governance.desktop_ui_specs_updated_with_surface_changes
    - repo.governance.desktop_ui_specs_not_broader_than_ecosystem
```
