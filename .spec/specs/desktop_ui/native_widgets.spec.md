# DesktopUi Native Widgets

This subject defines the target native widget surface that `desktop_ui` must
expose independently of canonical IUR.

## Related General Specs

- [Ecosystem Architecture](../architecture.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [DesktopUi Package](./package.spec.md)
- [DesktopUi Runtime](./runtime.spec.md)
- [DesktopUi SDL3 Runtime And Native Rendering](./sdl3_runtime_rendering.spec.md)
- [DesktopUi IUR Renderer](./iur_renderer.spec.md)

```spec-meta
id: desktop_ui.native_widgets
kind: subsystem
status: active
summary: Target native widget, layer, styling, and interaction surface for `desktop_ui` as a directly usable multiplatform desktop library.
surface:
  - packages/desktop_ui
  - .spec/specs/desktop_ui/native_widgets.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: desktop_ui.native_widgets.direct_native_surface
  statement: The package shall expose native desktop-oriented widgets, layout constructs, layering constructs, styling attributes, and interaction patterns that can be used directly without first loading canonical IUR.
  priority: must
  stability: stable

- id: desktop_ui.native_widgets.covers_canonical_iur_surface
  statement: The native `desktop_ui` surface shall be sufficient to realize every canonical `unified_iur` widget, layout, layering construct, and styling attribute required for ecosystem rendering.
  priority: must
  stability: stable

- id: desktop_ui.native_widgets.multiplatform_widget_meaning
  statement: Native widgets shall preserve shared canonical desktop meaning across Windows, macOS, and Linux even when the underlying platform realization or packaging differs.
  priority: must
  stability: stable

- id: desktop_ui.native_widgets.theme_and_style_surface
  statement: The package shall provide a native styling and theming surface that can express canonical styling and theming meaning while still being directly usable by native `desktop_ui` users, independent of whether pixels are ultimately presented through SDL3 renderer internals or a future bounded backend evolution.
  priority: must
  stability: stable

- id: desktop_ui.native_widgets.interaction_surface
  statement: The package shall provide native interaction patterns for keyboard-first focus, shortcuts, richer pointer input, menus, overlays, windows, and dynamic content in a way that can be mapped to and from canonical boundary event meaning.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: desktop_ui.native_widgets.build_native_desktop_flow
  covers:
    - desktop_ui.native_widgets.direct_native_surface
    - desktop_ui.native_widgets.covers_canonical_iur_surface
    - desktop_ui.native_widgets.multiplatform_widget_meaning
    - desktop_ui.native_widgets.theme_and_style_surface
    - desktop_ui.native_widgets.interaction_surface
  given:
    - A desktop application wants to build a multiwindow flow, dialog workflow, or data-heavy screen directly with `desktop_ui`
  when:
    - The application uses the package's native widget and style surface
  then:
    - It can compose a full native desktop experience without going through `unified_iur`
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/desktop_ui/native_widgets.spec.md
  covers:
    - desktop_ui.native_widgets.direct_native_surface
    - desktop_ui.native_widgets.covers_canonical_iur_surface
    - desktop_ui.native_widgets.multiplatform_widget_meaning
    - desktop_ui.native_widgets.theme_and_style_surface
    - desktop_ui.native_widgets.interaction_surface
    - desktop_ui.native_widgets.build_native_desktop_flow
```
