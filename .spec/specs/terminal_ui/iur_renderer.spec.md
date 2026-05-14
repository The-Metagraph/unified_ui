# TerminalUi IUR Renderer

This subject defines how `terminal_ui` consumes canonical `unified_iur` and
maps it into its native terminal widget surface.

## Related General Specs

- [Ecosystem Architecture](../architecture.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [TerminalUi Package](./package.spec.md)
- [TerminalUi Native Widgets](./native_widgets.spec.md)
- [TerminalUi Capabilities](./capabilities.spec.md)

```spec-meta
id: terminal_ui.iur_renderer
kind: subsystem
status: active
summary: Target canonical IUR renderer contract for `terminal_ui`, including full surface coverage, explicit degradation, and deterministic mapping into native terminal widgets.
surface:
  - packages/terminal_ui
  - .spec/specs/terminal_ui/iur_renderer.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: terminal_ui.iur_renderer.accepts_canonical_iur
  statement: The package shall accept canonical `unified_iur` as renderer input without requiring authored DSL modules or renderer-specific pretranslation layers outside the package.
  priority: must
  stability: stable

- id: terminal_ui.iur_renderer.full_construct_coverage
  statement: The renderer shall cover every canonical `unified_iur` widget, layout, layering construct, styling attribute, and interaction descriptor required by the root ecosystem contract, using explicit terminal-native degradation where the terminal medium cannot realize a richer construct directly.
  priority: must
  stability: stable

- id: terminal_ui.iur_renderer.deterministic_mapping
  statement: Equivalent canonical IUR input shall map deterministically into the same native `terminal_ui` widget structure, degradation choice, styling meaning, and interaction behavior for a given capability profile.
  priority: must
  stability: stable

- id: terminal_ui.iur_renderer.meaning_preservation
  statement: Canonical IUR meaning for hierarchy, layering, styling, theming, and interaction intent shall be preserved when realized through native `terminal_ui` widgets, including when terminal-native degradation is required.
  priority: must
  stability: stable

- id: terminal_ui.iur_renderer.native_widget_reuse
  statement: The canonical IUR renderer shall realize canonical meaning by reusing the package's native widget, styling, degradation, and runtime model rather than introducing a second unrelated rendering stack.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: terminal_ui.iur_renderer.render_canonical_screen
  covers:
    - terminal_ui.iur_renderer.accepts_canonical_iur
    - terminal_ui.iur_renderer.full_construct_coverage
    - terminal_ui.iur_renderer.deterministic_mapping
    - terminal_ui.iur_renderer.meaning_preservation
    - terminal_ui.iur_renderer.native_widget_reuse
  given:
    - A canonical IUR screen contains layered layouts, styled widgets, and interactive controls
  when:
    - `terminal_ui` renders that screen
  then:
    - The package maps the canonical structure into native terminal widgets while preserving canonical visual and interaction meaning through explicit capability-aware realization
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/terminal_ui/iur_renderer.spec.md
  covers:
    - terminal_ui.iur_renderer.accepts_canonical_iur
    - terminal_ui.iur_renderer.full_construct_coverage
    - terminal_ui.iur_renderer.deterministic_mapping
    - terminal_ui.iur_renderer.meaning_preservation
    - terminal_ui.iur_renderer.native_widget_reuse
    - terminal_ui.iur_renderer.render_canonical_screen
```
