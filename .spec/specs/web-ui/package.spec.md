# WebUi Package

This subject backfills the current package-level contract for
`packages/web_ui` from the implementation and local workflows that exist
today.

```spec-meta
id: web_ui.package
kind: package
status: active
summary: Current codebase-derived contract for the `packages/web_ui` library, its package metadata, dependency posture, and documented local workflows.
surface:
  - packages/web_ui/README.md
  - packages/web_ui/mix.exs
  - packages/web_ui/Makefile
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: web_ui.package.metadata
  statement: '`packages/web_ui` shall publish itself as the `:web_ui` library with the current Elixir requirement and the currently pinned `unified_iur` plus local `spec_led_ex` dependency posture declared in its package manifest.'
  priority: must
  stability: stable

- id: web_ui.package.local_workflows
  statement: 'The package shall expose the current documented local workflows for conformance, frontend assets, governance validation, and release readiness through its Mix aliases, Make targets, and README entrypoints.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/web_ui/mix.exs
  covers:
    - web_ui.package.metadata
    - web_ui.package.local_workflows

- kind: source_file
  target: packages/web_ui/README.md
  covers:
    - web_ui.package.local_workflows

- kind: source_file
  target: packages/web_ui/Makefile
  covers:
    - web_ui.package.local_workflows
```
