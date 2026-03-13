# WebUi Widget System

This subject defines the intended ecosystem-aligned native widget contract for
`packages/web_ui`.

```spec-meta
id: web_ui.widget_system
kind: subsystem
status: active
summary: Ecosystem-aligned widget-system contract for `packages/web_ui`, including an independent native widget catalog that renders canonical UnifiedIUR without becoming an authored DSL mirror.
surface:
  - packages/web_ui
  - .spec/specs/web-ui/widget_system.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.web_ui.ecosystem_alignment
```

## Requirements

```spec-requirements
- id: web_ui.widget_system.native_widget_independence
  statement: '`web_ui` may expose and evolve its own native widget system independently of the `unified_ui` DSL.'
  priority: must
  stability: stable

- id: web_ui.widget_system.renders_canonical_iur
  statement: 'The `web_ui` widget system shall render canonical UnifiedIUR using its own native widget catalog and shall not require authored DSL modules once canonical IUR is available.'
  priority: must
  stability: stable

- id: web_ui.widget_system.canonical_semantics_preserved
  statement: 'The native widget system shall preserve canonical widget identity and event meaning across server-side and frontend-side rendering boundaries.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/web-ui/widget_system.spec.md
  covers:
    - web_ui.widget_system.native_widget_independence
    - web_ui.widget_system.renders_canonical_iur
    - web_ui.widget_system.canonical_semantics_preserved
```
