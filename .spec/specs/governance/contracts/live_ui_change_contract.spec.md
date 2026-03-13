# LiveUi Change Contract

This contract defines how changes to `packages/live_ui` and its authored
ecosystem-aligned package subjects are governed in the centralized root `.spec`
workspace.

```spec-meta
id: repo.governance.live_ui_contract
kind: contract
status: active
summary: Governance contract for the ecosystem-aligned `live_ui` package subjects, including canonical IUR boundary, LiveView runtime, native rendering surface, and canonical transport.
surface:
  - packages/live_ui
  - .spec/specs/live-ui
decisions:
  - repo.governance.contract_policy
  - repo.governance.package_contract_policy
  - repo.live_ui.ecosystem_alignment
```

## Requirements

```spec-requirements
- id: repo.governance.live_ui_specs_updated_with_surface_changes
  statement: Changes to the `live_ui` package surface that affect its canonical UnifiedIUR boundary, native widget rendering model, LiveView runtime model, or canonical signal transport shall update the affected authored subjects under `.spec/specs/live-ui/` in the same change set.
  priority: must
  stability: stable

- id: repo.governance.live_ui_specs_not_broader_than_ecosystem
  statement: Authored subjects under `.spec/specs/live-ui/` shall remain aligned with the ecosystem architecture and signal transport decisions and shall not broaden the package contract with alternate authored source modes, non-canonical input boundaries, or package-local governance overlays unless those are first adopted into the root ecosystem or governance layer.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/governance/contracts/live_ui_change_contract.spec.md
  covers:
    - repo.governance.live_ui_specs_updated_with_surface_changes
    - repo.governance.live_ui_specs_not_broader_than_ecosystem
```
