# DesktopUi Change Contract

This contract defines how changes to `packages/desktop_ui` and its backfilled
package subjects are governed in the centralized root `.spec` workspace.

```spec-meta
id: repo.governance.desktop_ui_contract
kind: contract
status: active
summary: Governance contract for the current `desktop_ui` scaffold, documentation-backed architecture notes, and proof-of-concept planning specs.
surface:
  - packages/desktop_ui
  - .spec/specs/desktop-ui
decisions:
  - repo.governance.contract_policy
  - repo.governance.package_contract_policy
```

## Requirements

```spec-requirements
- id: repo.governance.desktop_ui_specs_updated_with_surface_changes
  statement: Changes to the current shipped `desktop_ui` Mix scaffold or public `DesktopUi` module shall update the affected authored subjects under `.spec/specs/desktop-ui/` in the same change set.
  priority: must
  stability: stable

- id: repo.governance.desktop_ui_docs_remain_current_truth
  statement: Changes to `packages/desktop_ui/notes/` or `CLAUDE.md` shall update the affected `desktop-ui` architecture or POC-plan subjects in the same change set, and those subjects shall not describe planned runtime layers as implemented package code until matching code exists.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/governance/contracts/desktop_ui_change_contract.spec.md
  covers:
    - repo.governance.desktop_ui_specs_updated_with_surface_changes
    - repo.governance.desktop_ui_docs_remain_current_truth
```
