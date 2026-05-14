# DesktopUi IUR Renderer

This subject defines how `desktop_ui` consumes canonical `unified_iur` and maps
it into its native desktop widget surface.

## Related General Specs

- [Ecosystem Architecture](../architecture.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [DesktopUi Package](./package.spec.md)
- [DesktopUi Native Widgets](./native_widgets.spec.md)

```spec-meta
id: desktop_ui.iur_renderer
kind: subsystem
status: active
summary: Target canonical IUR renderer contract for `desktop_ui`, including full surface coverage and deterministic mapping into native desktop widgets across Windows, macOS, and Linux.
surface:
  - packages/desktop_ui
  - .spec/specs/desktop_ui/iur_renderer.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: desktop_ui.iur_renderer.accepts_canonical_iur
  statement: The package shall accept canonical `unified_iur` as renderer input without requiring authored DSL modules or renderer-specific pretranslation layers outside the package.
  priority: must
  stability: stable

- id: desktop_ui.iur_renderer.full_construct_coverage
  statement: The renderer shall cover every canonical `unified_iur` widget, layout, layering construct, styling attribute, and interaction descriptor required by the root ecosystem contract.
  priority: must
  stability: stable

- id: desktop_ui.iur_renderer.deterministic_mapping
  statement: Equivalent canonical IUR input shall map deterministically into the same native `desktop_ui` widget structure, styling meaning, and interaction behavior across supported desktop targets.
  priority: must
  stability: stable

- id: desktop_ui.iur_renderer.meaning_preservation
  statement: Canonical IUR meaning for hierarchy, layering, styling, theming, and interaction intent shall be preserved when realized through native `desktop_ui` widgets.
  priority: must
  stability: stable

- id: desktop_ui.iur_renderer.native_widget_reuse
  statement: The canonical IUR renderer shall realize canonical meaning by reusing the package's native widget, styling, and runtime model rather than introducing a second unrelated rendering stack.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: desktop_ui.iur_renderer.render_canonical_screen
  covers:
    - desktop_ui.iur_renderer.accepts_canonical_iur
    - desktop_ui.iur_renderer.full_construct_coverage
    - desktop_ui.iur_renderer.deterministic_mapping
    - desktop_ui.iur_renderer.meaning_preservation
    - desktop_ui.iur_renderer.native_widget_reuse
  given:
    - A canonical IUR screen contains layered layouts, styled widgets, and interactive controls
  when:
    - `desktop_ui` renders that screen
  then:
    - The package maps the canonical structure into native desktop widgets while preserving canonical visual and interaction meaning across supported desktop targets
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/desktop_ui/iur_renderer.spec.md
  covers:
    - desktop_ui.iur_renderer.accepts_canonical_iur
    - desktop_ui.iur_renderer.full_construct_coverage
    - desktop_ui.iur_renderer.deterministic_mapping
    - desktop_ui.iur_renderer.meaning_preservation
    - desktop_ui.iur_renderer.native_widget_reuse
    - desktop_ui.iur_renderer.render_canonical_screen
```
