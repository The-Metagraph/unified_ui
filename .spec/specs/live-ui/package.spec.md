# LiveUi Package

This subject defines the intended ecosystem-aligned package contract for
`packages/live_ui`.

```spec-meta
id: live_ui.package
kind: package
status: active
summary: Ecosystem-aligned package contract for `packages/live_ui` as an independent Phoenix LiveView widget library that consumes canonical UnifiedIUR and canonical signal transport.
surface:
  - packages/live_ui
  - .spec/specs/live-ui
decisions:
  - repo.ecosystem.contract_model
  - repo.live_ui.ecosystem_alignment
```

## Requirements

```spec-requirements
- id: live_ui.package.library_position
  statement: '`live_ui` shall remain an independent Phoenix LiveView widget library and runtime package rather than an authored DSL boundary.'
  priority: must
  stability: stable

- id: live_ui.package.canonical_input_boundary
  statement: 'The authored cross-package input boundary for `live_ui` shall be canonical UnifiedIUR.'
  priority: must
  stability: stable

- id: live_ui.package.native_widget_independence
  statement: '`live_ui` may expose its own native widget surface and host integration helpers, but those conveniences shall not broaden or replace the canonical UnifiedIUR boundary.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/live-ui/package.spec.md
  covers:
    - live_ui.package.library_position
    - live_ui.package.canonical_input_boundary
    - live_ui.package.native_widget_independence
```
