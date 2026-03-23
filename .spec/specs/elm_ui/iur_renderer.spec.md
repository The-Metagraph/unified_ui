# ElmUi IUR Renderer

This subject defines how `elm_ui` consumes canonical `unified_iur` and maps it
into its native Phoenix-and-Elm widget surface.

## Related General Specs

- [Ecosystem Architecture](../architecture.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [ElmUi Package](./package.spec.md)
- [ElmUi Native Widgets](./native_widgets.spec.md)

```spec-meta
id: elm_ui.iur_renderer
kind: subsystem
status: active
summary: Target canonical IUR renderer contract for `elm_ui`, including full surface coverage and deterministic mapping into native web widgets across the Phoenix-and-Elm split.
surface:
  - packages/elm_ui
  - .spec/specs/elm_ui/iur_renderer.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.elm_ui_naming
```

## Requirements

```spec-requirements
- id: elm_ui.iur_renderer.accepts_canonical_iur
  statement: The package shall accept canonical `unified_iur` as renderer input without requiring authored DSL modules or renderer-specific pretranslation layers outside the package.
  priority: must
  stability: stable

- id: elm_ui.iur_renderer.full_construct_coverage
  statement: The renderer shall cover every canonical `unified_iur` widget, layout, layering construct, styling attribute, and interaction descriptor required by the root ecosystem contract.
  priority: must
  stability: stable

- id: elm_ui.iur_renderer.deterministic_mapping
  statement: Equivalent canonical IUR input shall map deterministically into the same native `elm_ui` widget structure, styling meaning, and interaction behavior across the Phoenix-and-Elm split.
  priority: must
  stability: stable

- id: elm_ui.iur_renderer.meaning_preservation
  statement: Canonical IUR meaning for hierarchy, layering, styling, theming, and interaction intent shall be preserved when realized through native `elm_ui` widgets.
  priority: must
  stability: stable

- id: elm_ui.iur_renderer.native_widget_reuse
  statement: The canonical IUR renderer shall realize canonical meaning by reusing the package's native widget, styling, frontend, and runtime model rather than introducing a second unrelated rendering stack.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: elm_ui.iur_renderer.render_canonical_screen
  given: A canonical IUR screen contains layered layouts, styled widgets, and interactive controls
  when: `elm_ui` renders that screen
  then: The package maps the canonical structure into native web widgets across Phoenix and Elm while preserving canonical visual and interaction meaning
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/elm_ui/iur_renderer.spec.md
  covers:
    - elm_ui.iur_renderer.accepts_canonical_iur
    - elm_ui.iur_renderer.full_construct_coverage
    - elm_ui.iur_renderer.deterministic_mapping
    - elm_ui.iur_renderer.meaning_preservation
    - elm_ui.iur_renderer.native_widget_reuse
    - elm_ui.iur_renderer.render_canonical_screen
```
