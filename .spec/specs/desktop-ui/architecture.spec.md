# DesktopUi Architecture

This subject defines the intended ecosystem-aligned native widget architecture
for `packages/desktop_ui`.

```spec-meta
id: desktop_ui.architecture
kind: subsystem
status: active
summary: Ecosystem-aligned native widget architecture for `packages/desktop_ui`, including an independent desktop widget system that renders canonical UnifiedIUR without becoming an authored DSL mirror.
surface:
  - packages/desktop_ui
  - .spec/specs/desktop-ui/architecture.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.desktop_ui.ecosystem_alignment
```

## Requirements

```spec-requirements
- id: desktop_ui.architecture.native_widget_independence
  statement: '`desktop_ui` may expose and evolve its own native desktop widget system independently of the `unified_ui` DSL.'
  priority: must
  stability: stable

- id: desktop_ui.architecture.renders_canonical_iur
  statement: 'The `desktop_ui` architecture shall render canonical UnifiedIUR using its own native widget and layout system and shall not require authored DSL modules once canonical IUR is available.'
  priority: must
  stability: stable

- id: desktop_ui.architecture.canonical_semantics_preserved
  statement: 'The native desktop architecture shall preserve canonical widget identity and event meaning across runtime, layout, rendering, and platform input boundaries.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/desktop-ui/architecture.spec.md
  covers:
    - desktop_ui.architecture.native_widget_independence
    - desktop_ui.architecture.renders_canonical_iur
    - desktop_ui.architecture.canonical_semantics_preserved
```
