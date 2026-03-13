# UnifiedIUR Package

This subject backfills the current package-level contract for
`packages/unified_iur` from the code that exists today.

```spec-meta
id: unified_iur.package
kind: package
status: active
summary: Current codebase-derived contract for the `packages/unified_iur` library, its published package metadata, and its top-level public type surface.
surface:
  - packages/unified_iur/README.md
  - packages/unified_iur/mix.exs
  - packages/unified_iur/lib/unified_iur.ex
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: unified_iur.package.metadata
  statement: `packages/unified_iur` shall publish itself as the `:unified_iur` library and declare the current package metadata, documentation entrypoints, and pure intermediate-representation positioning in its package manifest and README.
  priority: must
  stability: stable

- id: unified_iur.package.public_types
  statement: The top-level `UnifiedIUR` module shall expose the current public type aliases for the implemented widget, layout, and style structs.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/unified_iur/mix.exs
  covers:
    - unified_iur.package.metadata

- kind: source_file
  target: packages/unified_iur/README.md
  covers:
    - unified_iur.package.metadata

- kind: source_file
  target: packages/unified_iur/lib/unified_iur.ex
  covers:
    - unified_iur.package.public_types
```
