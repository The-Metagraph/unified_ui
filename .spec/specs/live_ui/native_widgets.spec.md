# LiveUi Native Widgets

This subject defines the target native widget surface that `live_ui` must expose
independently of canonical IUR.

## Related General Specs

- [Ecosystem Architecture](../architecture.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [LiveUi Package](./package.spec.md)
- [LiveUi Runtime](./runtime.spec.md)
- [LiveUi IUR Renderer](./iur_renderer.spec.md)

```spec-meta
id: live_ui.native_widgets
kind: subsystem
status: active
summary: Target native widget, layer, styling, and interaction surface for `live_ui` as a directly usable LiveView library.
surface:
  - packages/live_ui
  - .spec/specs/live_ui/native_widgets.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: live_ui.native_widgets.direct_native_surface
  statement: The package shall expose native LiveView-oriented widgets, layout constructs, layering constructs, styling attributes, and interaction patterns that can be used directly without first loading canonical IUR.
  priority: must
  stability: stable

- id: live_ui.native_widgets.covers_canonical_iur_surface
  statement: The native `live_ui` surface shall be sufficient to realize every canonical `unified_iur` widget, layout, layering construct, and styling attribute required for ecosystem rendering.
  priority: must
  stability: stable

- id: live_ui.native_widgets.liveview_native_composition
  statement: Native widgets shall compose naturally through Phoenix LiveView and HEEx-oriented composition patterns rather than pretending to be authored DSL modules.
  priority: must
  stability: stable

- id: live_ui.native_widgets.theme_and_style_surface
  statement: The package shall provide a native styling and theming surface that can express canonical styling and theming meaning while still being directly usable by native `live_ui` users.
  priority: must
  stability: stable

- id: live_ui.native_widgets.interaction_surface
  statement: The package shall provide native interaction patterns for user input, navigation, dialogs, overlays, and dynamic content updates in a way that can be mapped to and from canonical boundary event meaning.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: live_ui.native_widgets.build_native_flow
  given: A Phoenix application wants to build a multi-step dialog or dashboard directly with `live_ui`
  when: The application uses the package's native widget and style surface
  then: It can compose a full LiveView-native experience without going through `unified_iur`
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/live_ui/native_widgets.spec.md
  covers:
    - live_ui.native_widgets.direct_native_surface
    - live_ui.native_widgets.covers_canonical_iur_surface
    - live_ui.native_widgets.liveview_native_composition
    - live_ui.native_widgets.theme_and_style_surface
    - live_ui.native_widgets.interaction_surface
    - live_ui.native_widgets.build_native_flow
```
