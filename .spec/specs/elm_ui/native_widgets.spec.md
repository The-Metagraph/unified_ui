# ElmUi Native Widgets

This subject defines the target native widget surface that `elm_ui` must expose
independently of canonical IUR.

## Related General Specs

- [Ecosystem Architecture](../architecture.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [ElmUi Package](./package.spec.md)
- [ElmUi Server Runtime](./server_runtime.spec.md)
- [ElmUi Frontend Runtime](./frontend_runtime.spec.md)
- [ElmUi IUR Renderer](./iur_renderer.spec.md)

```spec-meta
id: elm_ui.native_widgets
kind: subsystem
status: active
summary: Target native widget, layer, styling, and interaction surface for `elm_ui` as a directly usable web library.
surface:
  - packages/elm_ui
  - .spec/specs/elm_ui/native_widgets.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.elm_ui_naming
```

## Requirements

```spec-requirements
- id: elm_ui.native_widgets.direct_native_surface
  statement: The package shall expose native web-oriented widgets, layout constructs, layering constructs, styling attributes, and interaction patterns that can be used directly without first loading canonical IUR.
  priority: must
  stability: stable

- id: elm_ui.native_widgets.covers_canonical_iur_surface
  statement: The native `elm_ui` surface shall be sufficient to realize every canonical `unified_iur` widget, layout, layering construct, and styling attribute required for ecosystem rendering.
  priority: must
  stability: stable

- id: elm_ui.native_widgets.server_client_composition
  statement: Native widgets shall compose through the package's Phoenix server-side representation and Elm client-side rendering model rather than pretending to be authored DSL modules.
  priority: must
  stability: stable

- id: elm_ui.native_widgets.theme_and_style_surface
  statement: The package shall provide a native styling and theming surface that can express canonical styling and theming meaning while still being directly usable by native `elm_ui` users.
  priority: must
  stability: stable

- id: elm_ui.native_widgets.interaction_surface
  statement: The package shall provide native interaction patterns for forms, navigation, overlays, dynamic content, and browser-oriented behaviors in a way that can be mapped to and from canonical boundary event meaning.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: elm_ui.native_widgets.build_native_web_flow
  given: A web application wants to build a multi-step dialog, dashboard, or interactive form directly with `elm_ui`
  when: The application uses the package's native widget and style surface
  then: It can compose a full Phoenix-and-Elm-native experience without going through `unified_iur`
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/elm_ui/native_widgets.spec.md
  covers:
    - elm_ui.native_widgets.direct_native_surface
    - elm_ui.native_widgets.covers_canonical_iur_surface
    - elm_ui.native_widgets.server_client_composition
    - elm_ui.native_widgets.theme_and_style_surface
    - elm_ui.native_widgets.interaction_surface
    - elm_ui.native_widgets.build_native_web_flow
```
