# DesktopUi Runtime

This subject defines the intended ecosystem-aligned runtime contract for
`packages/desktop_ui`.

```spec-meta
id: desktop_ui.runtime
kind: runtime
status: active
summary: Ecosystem-aligned runtime contract for `packages/desktop_ui`, using an SDL2-based desktop runtime across Windows, macOS, and Linux while preserving canonical rendering and signal semantics.
surface:
  - packages/desktop_ui
  - .spec/specs/desktop-ui/runtime.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.desktop_ui.ecosystem_alignment
```

## Requirements

```spec-requirements
- id: desktop_ui.runtime.sdl2_targets
  statement: '`desktop_ui` shall target Windows, macOS, and Linux through an SDL2-based desktop runtime.'
  priority: must
  stability: stable

- id: desktop_ui.runtime.canonical_runtime_boundary
  statement: 'The desktop runtime shall preserve canonical UnifiedIUR and canonical signal semantics across layout, rendering, and platform-bridge boundaries rather than introducing an alternate authored runtime contract.'
  priority: must
  stability: stable

- id: desktop_ui.runtime.local_state_subordinate
  statement: 'Renderer-local or platform-local state may exist for runtime execution, but it shall remain subordinate to the canonical rendering and signal contract rather than redefining cross-package UI meaning.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/desktop-ui/runtime.spec.md
  covers:
    - desktop_ui.runtime.sdl2_targets
    - desktop_ui.runtime.canonical_runtime_boundary
    - desktop_ui.runtime.local_state_subordinate
```
