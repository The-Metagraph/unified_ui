# WebUi Change Contract

This contract defines how changes to `packages/web_ui` and its authored
ecosystem-aligned package subjects are governed in the centralized root `.spec`
workspace.

```spec-meta
id: repo.governance.web_ui_contract
kind: contract
status: active
summary: Governance contract for the ecosystem-aligned `web_ui` package subjects, including canonical IUR boundary, native widget system, Phoenix and Elm runtime split, and canonical transport.
surface:
  - packages/web_ui
  - .spec/specs/web-ui
decisions:
  - repo.governance.contract_policy
  - repo.governance.package_contract_policy
  - repo.web_ui.ecosystem_alignment
```

## Requirements

```spec-requirements
- id: repo.governance.web_ui_specs_updated_with_surface_changes
  statement: Changes to the `web_ui` package surface that affect its canonical UnifiedIUR boundary, native widget system, Phoenix server runtime, Elm frontend runtime, or canonical transport shall update the affected authored subjects under `.spec/specs/web-ui/` in the same change set.
  priority: must
  stability: stable

- id: repo.governance.web_ui_specs_not_broader_than_ecosystem
  statement: Authored subjects under `.spec/specs/web-ui/` shall remain aligned with the ecosystem architecture, runtime, and signal transport decisions and shall not broaden the package contract with package-local tooling, persistence, observability, release, or other implementation-specific overlays unless those are first adopted into the root ecosystem or governance layer.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/governance/contracts/web_ui_change_contract.spec.md
  covers:
    - repo.governance.web_ui_specs_updated_with_surface_changes
    - repo.governance.web_ui_specs_not_broader_than_ecosystem
```
