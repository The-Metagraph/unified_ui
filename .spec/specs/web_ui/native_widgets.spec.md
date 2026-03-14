# WebUi Native Widgets

This subject defines the target native widget surface that `web_ui` must expose
independently of canonical IUR.

## Related General Specs

- [Ecosystem Architecture](../architecture.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [WebUi Package](./package.spec.md)
- [WebUi Server Runtime](./server_runtime.spec.md)
- [WebUi Frontend Runtime](./frontend_runtime.spec.md)
- [WebUi IUR Renderer](./iur_renderer.spec.md)

```spec-meta
id: web_ui.native_widgets
kind: subsystem
status: active
summary: Target native widget, layer, styling, and interaction surface for `web_ui` as a directly usable web library.
surface:
  - packages/web_ui
  - .spec/specs/web_ui/native_widgets.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: web_ui.native_widgets.direct_native_surface
  statement: The package shall expose native web-oriented widgets, layout constructs, layering constructs, styling attributes, and interaction patterns that can be used directly without first loading canonical IUR.
  priority: must
  stability: stable

- id: web_ui.native_widgets.covers_canonical_iur_surface
  statement: The native `web_ui` surface shall be sufficient to realize every canonical `unified_iur` widget, layout, layering construct, and styling attribute required for ecosystem rendering.
  priority: must
  stability: stable

- id: web_ui.native_widgets.server_client_composition
  statement: Native widgets shall compose through the package's Phoenix server-side representation and Elm client-side rendering model rather than pretending to be authored DSL modules.
  priority: must
  stability: stable

- id: web_ui.native_widgets.theme_and_style_surface
  statement: The package shall provide a native styling and theming surface that can express canonical styling and theming meaning while still being directly usable by native `web_ui` users.
  priority: must
  stability: stable

- id: web_ui.native_widgets.interaction_surface
  statement: The package shall provide native interaction patterns for forms, navigation, overlays, dynamic content, and browser-oriented behaviors in a way that can be mapped to and from canonical boundary event meaning.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: web_ui.native_widgets.build_native_web_flow
  given: A web application wants to build a multi-step dialog, dashboard, or interactive form directly with `web_ui`
  when: The application uses the package's native widget and style surface
  then: It can compose a full Phoenix-and-Elm-native experience without going through `unified_iur`
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/web_ui/native_widgets.spec.md
  covers:
    - web_ui.native_widgets.direct_native_surface
    - web_ui.native_widgets.covers_canonical_iur_surface
    - web_ui.native_widgets.server_client_composition
    - web_ui.native_widgets.theme_and_style_surface
    - web_ui.native_widgets.interaction_surface
    - web_ui.native_widgets.build_native_web_flow
```
