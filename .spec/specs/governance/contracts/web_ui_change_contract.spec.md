# WebUi Change Contract

This contract defines how changes to `packages/web_ui` and its backfilled
package subjects are governed in the centralized root `.spec` workspace.

```spec-meta
id: repo.governance.web_ui_contract
kind: contract
status: active
summary: Governance contract for the current `web_ui` transport, widget, runtime, frontend, persistence, observability, and tooling backfill.
surface:
  - packages/web_ui
  - .spec/specs/web-ui
decisions:
  - repo.governance.contract_policy
  - repo.governance.package_contract_policy
```

## Requirements

```spec-requirements
- id: repo.governance.web_ui_specs_updated_with_surface_changes
  statement: Changes to the current `web_ui` transport, widget system, IUR interpretation, runtime authority, frontend runtime, persistence, or observability code shall update the affected authored subjects under `.spec/specs/web-ui/` in the same change set.
  priority: must
  stability: stable

- id: repo.governance.web_ui_tooling_backfill_kept_in_sync
  statement: Changes to the current `web_ui` governance, conformance, release-readiness, or frontend parity automation under `packages/web_ui/scripts/`, `.githooks/`, `.github/workflows/`, `rfcs/`, or `specs/` shall update `.spec/specs/web-ui/tooling.spec.md` in the same change set and shall remain grounded in shipped package tooling rather than ecosystem governance.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/governance/contracts/web_ui_change_contract.spec.md
  covers:
    - repo.governance.web_ui_specs_updated_with_surface_changes
    - repo.governance.web_ui_tooling_backfill_kept_in_sync
```
