# LiveUi Change Contract

This contract defines how changes to `packages/live_ui` and its backfilled
package subjects are governed in the centralized root `.spec` workspace.

```spec-meta
id: repo.governance.live_ui_contract
kind: contract
status: active
summary: Governance contract for the current `live_ui` rendering, interpreter, runtime, host entrypoint, and local specs-overlay backfill.
surface:
  - packages/live_ui
  - .spec/specs/live-ui
decisions:
  - repo.governance.contract_policy
  - repo.governance.package_contract_policy
```

## Requirements

```spec-requirements
- id: repo.governance.live_ui_specs_updated_with_surface_changes
  statement: Changes to the current `live_ui` rendering, interpreter, runtime, session, routing, or host-entrypoint code shall update the affected authored subjects under `.spec/specs/live-ui/` in the same change set.
  priority: must
  stability: stable

- id: repo.governance.live_ui_local_overlay_kept_in_sync
  statement: Changes to the shipped `live_ui` local specs-governance overlay under `packages/live_ui/lib/live_ui/specs*` or the `mix live_ui.spec.check` entrypoint shall update `.spec/specs/live-ui/local_specs.spec.md` in the same change set and shall remain grounded in the package’s current code rather than ecosystem-level governance.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/governance/contracts/live_ui_change_contract.spec.md
  covers:
    - repo.governance.live_ui_specs_updated_with_surface_changes
    - repo.governance.live_ui_local_overlay_kept_in_sync
```
