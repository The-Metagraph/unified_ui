# TerminalUi Native Widgets

This subject defines the target native widget surface that `terminal_ui` must
expose independently of canonical IUR.

## Related General Specs

- [Ecosystem Architecture](../architecture.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [TerminalUi Package](./package.spec.md)
- [TerminalUi Runtime](./runtime.spec.md)
- [TerminalUi Capabilities](./capabilities.spec.md)
- [TerminalUi IUR Renderer](./iur_renderer.spec.md)

```spec-meta
id: terminal_ui.native_widgets
kind: subsystem
status: active
summary: Target native widget, display, styling, and interaction surface for `terminal_ui` as a directly usable terminal library.
surface:
  - packages/terminal_ui
  - .spec/specs/terminal_ui/native_widgets.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.widget_portability_from_ash_ui
```

## Requirements

```spec-requirements
- id: terminal_ui.native_widgets.direct_native_surface
  statement: The package shall expose native terminal-oriented widgets, layout constructs, layering constructs, styling attributes, and interaction patterns that can be used directly without first loading canonical IUR.
  priority: must
  stability: stable

- id: terminal_ui.native_widgets.covers_canonical_iur_surface
  statement: The native `terminal_ui` surface shall be sufficient to realize every canonical `unified_iur` widget, layout, layering construct, and styling attribute required for ecosystem rendering, either directly or through explicit terminal-native degradation rules that preserve core meaning.
  priority: must
  stability: stable

- id: terminal_ui.native_widgets.capability_aware_widget_meaning
  statement: Native widgets shall preserve shared canonical terminal meaning across richer and limited terminal environments even when the underlying realization degrades because of backend or terminal capability limits.
  priority: must
  stability: stable

- id: terminal_ui.native_widgets.theme_and_style_surface
  statement: The package shall provide a native styling and theming surface that can express canonical styling and theming meaning while still being directly usable by native `terminal_ui` users and degradable across terminal capability profiles.
  priority: must
  stability: stable

- id: terminal_ui.native_widgets.interaction_surface
  statement: The package shall provide native interaction patterns for keyboard, mouse when available, focus, shortcuts, overlays, resize, paste, and dynamic terminal content in a way that can be mapped to and from canonical boundary event meaning.
  priority: must
  stability: stable

- id: terminal_ui.native_widgets.promoted_widget_equivalents
  statement: The native `terminal_ui` surface shall provide terminal-native or explicitly degraded equivalents for the promoted AshUi-originated canonical widgets, including disclosure, semantic micro-status, segmented controls, multi-column rows, sticky headers, workflow progress, slide-over panels, event callouts, inline redline text, syntax-highlighted code blocks, chat composers, and host-owned form shells.
  priority: must
  stability: stable

- id: terminal_ui.native_widgets.repeated_collection_realization
  statement: The native `terminal_ui` surface and canonical renderer path shall realize repeated collection composition through terminal-appropriate lists, panels, or virtualized regions while preserving row-scope binding meaning across capability profiles.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: terminal_ui.native_widgets.build_native_terminal_flow
  covers:
    - terminal_ui.native_widgets.direct_native_surface
    - terminal_ui.native_widgets.covers_canonical_iur_surface
    - terminal_ui.native_widgets.capability_aware_widget_meaning
    - terminal_ui.native_widgets.theme_and_style_surface
    - terminal_ui.native_widgets.interaction_surface
    - terminal_ui.native_widgets.promoted_widget_equivalents
    - terminal_ui.native_widgets.repeated_collection_realization
  given:
    - A terminal application wants to build a keyboard-first workflow, dialog flow, dashboard, or data-heavy screen directly with `terminal_ui`
  when:
    - The application uses the package's native widget and style surface
  then:
    - It can compose a full native terminal experience without going through `unified_iur`
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/terminal_ui/native_widgets.spec.md
  covers:
    - terminal_ui.native_widgets.direct_native_surface
    - terminal_ui.native_widgets.covers_canonical_iur_surface
    - terminal_ui.native_widgets.capability_aware_widget_meaning
    - terminal_ui.native_widgets.theme_and_style_surface
    - terminal_ui.native_widgets.interaction_surface
    - terminal_ui.native_widgets.promoted_widget_equivalents
    - terminal_ui.native_widgets.repeated_collection_realization
```
