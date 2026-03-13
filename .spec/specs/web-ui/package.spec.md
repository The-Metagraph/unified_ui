# WebUi Package

This subject defines the intended ecosystem-aligned package contract for
`packages/web_ui`.

```spec-meta
id: web_ui.package
kind: package
status: active
summary: Ecosystem-aligned package contract for `packages/web_ui` as an independent widget library with a Phoenix server runtime, an Elm frontend runtime, canonical UnifiedIUR input, and canonical signal transport.
surface:
  - packages/web_ui
  - .spec/specs/web-ui
decisions:
  - repo.ecosystem.contract_model
  - repo.web_ui.ecosystem_alignment
```

## Requirements

```spec-requirements
- id: web_ui.package.library_position
  statement: '`web_ui` shall remain an independent widget library rather than an authored DSL boundary.'
  priority: must
  stability: stable

- id: web_ui.package.canonical_input_boundary
  statement: 'The authored cross-package input boundary for `web_ui` shall be canonical UnifiedIUR.'
  priority: must
  stability: stable

- id: web_ui.package.runtime_split
  statement: '`web_ui` shall use Phoenix for server-side runtime representation and Elm for client-side rendering and local state.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/web-ui/package.spec.md
  covers:
    - web_ui.package.library_position
    - web_ui.package.canonical_input_boundary
    - web_ui.package.runtime_split
```
