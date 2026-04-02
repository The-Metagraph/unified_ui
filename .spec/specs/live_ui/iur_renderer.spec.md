# LiveUi IUR Renderer

This subject defines how `live_ui` consumes canonical `unified_iur` and maps it
into its native LiveView widget surface.

## Related General Specs

- [Ecosystem Architecture](../architecture.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [LiveUi Package](./package.spec.md)
- [LiveUi Native Widgets](./native_widgets.spec.md)

```spec-meta
id: live_ui.iur_renderer
kind: subsystem
status: active
summary: Target canonical IUR renderer contract for `live_ui`, including full surface coverage and deterministic mapping into native widget component boundaries.
surface:
  - packages/live_ui
  - .spec/specs/live_ui/iur_renderer.spec.md
decisions:
  - repo.ecosystem.contract_model
  - live_ui.runtime.widget_livecomponents
```

## Requirements

```spec-requirements
- id: live_ui.iur_renderer.accepts_canonical_iur
  statement: The package shall accept canonical `unified_iur` as renderer input without requiring authored DSL modules or renderer-specific pretranslation layers outside the package.
  priority: must
  stability: stable

- id: live_ui.iur_renderer.full_construct_coverage
  statement: The renderer shall cover every canonical `unified_iur` widget, layout, layering construct, styling attribute, and interaction descriptor required by the root ecosystem contract.
  priority: must
  stability: stable

- id: live_ui.iur_renderer.deterministic_mapping
  statement: Equivalent canonical IUR input shall map deterministically into the same native `live_ui` widget structure, styling meaning, and interaction behavior.
  priority: must
  stability: stable

- id: live_ui.iur_renderer.meaning_preservation
  statement: Canonical IUR meaning for hierarchy, layering, styling, theming, and interaction intent shall be preserved when realized through native `live_ui` widgets.
  priority: must
  stability: stable

- id: live_ui.iur_renderer.native_widget_reuse
  statement: The canonical IUR renderer shall realize canonical meaning by reusing the package's native widget, styling, and runtime model rather than introducing a second unrelated rendering stack.
  priority: must
  stability: stable

- id: live_ui.iur_renderer.targets_widget_component_boundaries
  statement: Canonical IUR constructs shall map into the same mountable widget component boundaries used by direct native `live_ui` usage rather than into a renderer-only widget realization path.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: live_ui.iur_renderer.render_canonical_screen
  given: A canonical IUR screen contains layered layouts, styled widgets, and interactive controls
  when: `live_ui` renders that screen
  then: The package maps the canonical structure into native widget component boundaries while preserving canonical visual and interaction meaning
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/live_ui/iur_renderer.spec.md
  covers:
    - live_ui.iur_renderer.accepts_canonical_iur
    - live_ui.iur_renderer.full_construct_coverage
    - live_ui.iur_renderer.deterministic_mapping
    - live_ui.iur_renderer.meaning_preservation
    - live_ui.iur_renderer.native_widget_reuse
    - live_ui.iur_renderer.targets_widget_component_boundaries
    - live_ui.iur_renderer.render_canonical_screen
```
