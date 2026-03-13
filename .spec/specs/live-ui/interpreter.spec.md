# LiveUi Interpreter

This subject defines the intended ecosystem-aligned interpretation boundary for
`packages/live_ui`.

```spec-meta
id: live_ui.interpreter
kind: integration
status: active
summary: Ecosystem-aligned interpretation contract for `packages/live_ui`, centered on canonical UnifiedIUR input and normalized internal render structures.
surface:
  - packages/live_ui
  - .spec/specs/live-ui/interpreter.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.live_ui.ecosystem_alignment
```

## Requirements

```spec-requirements
- id: live_ui.interpreter.canonical_iur_input
  statement: '`live_ui` shall interpret canonical UnifiedIUR as its authoritative cross-package rendering input.'
  priority: must
  stability: stable

- id: live_ui.interpreter.normalized_render_tree
  statement: 'The library shall normalize canonical UnifiedIUR into internal render structures that preserve widget identity, structure, props, children, and canonical signal bindings for LiveView rendering.'
  priority: must
  stability: stable

- id: live_ui.interpreter.input_boundary_not_broadened
  statement: 'The authored package contract shall not broaden the ecosystem rendering boundary by requiring module-backed screen sources, structurally compatible non-canonical extension inputs, or other alternate authored source shapes.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/live-ui/interpreter.spec.md
  covers:
    - live_ui.interpreter.canonical_iur_input
    - live_ui.interpreter.normalized_render_tree
    - live_ui.interpreter.input_boundary_not_broadened
```
