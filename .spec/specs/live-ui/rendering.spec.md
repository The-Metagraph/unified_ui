# LiveUi Rendering

This subject defines the intended ecosystem-aligned rendering contract for
`packages/live_ui`.

```spec-meta
id: live_ui.rendering
kind: subsystem
status: active
summary: Ecosystem-aligned rendering contract for `packages/live_ui`, including an independent native widget surface, LiveView component rendering, and minimized hook usage.
surface:
  - packages/live_ui
  - .spec/specs/live-ui/rendering.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.live_ui.ecosystem_alignment
```

## Requirements

```spec-requirements
- id: live_ui.rendering.native_widget_library
  statement: '`live_ui` shall render canonical UnifiedIUR through its own native Phoenix LiveView widget and layout surface rather than acting as a thin authored DSL mirror.'
  priority: must
  stability: stable

- id: live_ui.rendering.canonical_signal_markup
  statement: 'The rendered LiveView surface shall preserve canonical widget identity and signal metadata needed to carry canonical event meaning through the runtime boundary.'
  priority: must
  stability: stable

- id: live_ui.rendering.hooks_only_when_necessary
  statement: 'JavaScript hooks shall be used only where they are necessary to bridge canonical signals and local widget behavior that cannot be expressed through plain LiveView rendering alone.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/live-ui/rendering.spec.md
  covers:
    - live_ui.rendering.native_widget_library
    - live_ui.rendering.canonical_signal_markup
    - live_ui.rendering.hooks_only_when_necessary
```
