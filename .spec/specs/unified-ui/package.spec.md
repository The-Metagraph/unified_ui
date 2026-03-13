# UnifiedUi Package

This subject backfills the current package-level contract for `packages/unified-ui`
from the implementation that exists today.

```spec-meta
id: unified_ui.package
kind: package
status: active
summary: Current codebase-derived contract for the `packages/unified-ui` library, its published package metadata, and its OTP runtime support.
surface:
  - packages/unified-ui/README.md
  - packages/unified-ui/mix.exs
  - packages/unified-ui/lib/unified_ui.ex
  - packages/unified-ui/lib/unified_ui/application.ex
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: unified_ui.package.metadata
  statement: `packages/unified-ui` shall publish itself as the `:unified_ui` library and declare the current multi-platform DSL, renderer, signal, and `unified_iur`-facing package metadata in its package manifest and top-level module.
  priority: must
  stability: stable

- id: unified_ui.package.runtime_boot
  statement: The package OTP application shall start the PubSub, registry, and dynamic supervisor infrastructure needed by the current signal bus and component agent runtime.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/unified-ui/mix.exs
  covers:
    - unified_ui.package.metadata

- kind: source_file
  target: packages/unified-ui/lib/unified_ui.ex
  covers:
    - unified_ui.package.metadata

- kind: source_file
  target: packages/unified-ui/lib/unified_ui/application.ex
  covers:
    - unified_ui.package.runtime_boot

- kind: source_file
  target: packages/unified-ui/test/unified_ui/unified_ui_test.exs
  covers:
    - unified_ui.package.metadata
```
