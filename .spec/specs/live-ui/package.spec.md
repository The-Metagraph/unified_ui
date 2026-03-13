# LiveUi Package

This subject backfills the current package-level contract for
`packages/live_ui` from the implementation that exists today.

```spec-meta
id: live_ui.package
kind: package
status: active
summary: Current codebase-derived contract for the `packages/live_ui` library, its published package metadata, and its top-level host integration entrypoints.
surface:
  - packages/live_ui/README.md
  - packages/live_ui/mix.exs
  - packages/live_ui/lib/live_ui.ex
  - packages/live_ui/test/live_ui/architecture/package_contract_test.exs
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: live_ui.package.metadata
  statement: 'The package shall publish itself as the `:live_ui` library and declare its current positioning as a LiveView adapter and runtime shell for UnifiedUi screens and canonical UnifiedIUR sources.'
  priority: must
  stability: stable

- id: live_ui.package.host_entrypoints
  statement: 'The top-level `LiveUi` module shall expose the current dynamic session envelope helpers and session extraction entrypoints used by host applications.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/live_ui/mix.exs
  covers:
    - live_ui.package.metadata

- kind: source_file
  target: packages/live_ui/lib/live_ui.ex
  covers:
    - live_ui.package.host_entrypoints

- kind: source_file
  target: packages/live_ui/test/live_ui/architecture/package_contract_test.exs
  covers:
    - live_ui.package.host_entrypoints
```
