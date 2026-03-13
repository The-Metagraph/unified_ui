# Platform Runtimes

This subject defines the renderer and widget-library responsibilities for the ecosystem runtime packages.

```spec-meta
id: ecosystem.platform_runtimes
kind: architecture
status: active
summary: Architecture contract for `web_ui`, `live_ui`, and `desktop_ui` as native widget and signal libraries that also include canonical IUR renderers.
surface:
  - packages/web_ui
  - packages/live_ui
  - packages/desktop_ui
  - .spec/specs/platform_runtimes.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: ecosystem.platform_runtimes.widget_libraries_independent
  statement: Each widget library may expose and evolve its own native widget set independently of the `unified_ui` DSL.
  priority: must
  stability: stable

- id: ecosystem.platform_runtimes.native_surface_covers_iur
  statement: Each widget library shall contain native widgets, layering constructs, and styling attributes sufficient to represent every canonical `unified_iur` widget, layout, layering, and styling construct required for ecosystem rendering.
  priority: must
  stability: stable

- id: ecosystem.platform_runtimes.native_surface_usable_without_iur
  statement: Each widget library's native widgets, layering constructs, styling attributes, and local interaction model shall be usable directly without first loading canonical IUR.
  priority: must
  stability: stable

- id: ecosystem.platform_runtimes.iur_interpretation
  statement: Each widget library shall include an IUR renderer that interprets canonical `unified_iur` input and renders it using its own native widget system, layering model, styling attributes, and native signal model.
  priority: must
  stability: stable

- id: ecosystem.platform_runtimes.web_ui_runtime_split
  statement: `web_ui` shall use Phoenix for server-side runtime representation and Elm for client-side rendering and local state while preserving canonical IUR meaning and canonical event meaning at the ecosystem boundary.
  priority: must
  stability: stable

- id: ecosystem.platform_runtimes.live_ui_runtime
  statement: `live_ui` shall use Phoenix LiveView components with JavaScript hooks only where necessary while preserving canonical IUR meaning and canonical event meaning at the ecosystem boundary.
  priority: must
  stability: stable

- id: ecosystem.platform_runtimes.desktop_ui_targets
  statement: `desktop_ui` shall target Windows, macOS, and Linux using an SDL2-based desktop runtime with its own native widget set.
  priority: must
  stability: stable

- id: ecosystem.platform_runtimes.desktop_ui_native_runtime
  statement: `desktop_ui` shall expose a native desktop runtime and widget model that is usable directly, with canonical IUR rendering provided as a renderer entry point rather than the only runtime entry point.
  priority: must
  stability: stable
```

## Exceptions

```spec-exceptions
- id: ecosystem.platform_runtimes.desktop_runtime_evolving
  covers:
    - ecosystem.platform_runtimes.desktop_ui_targets
    - ecosystem.platform_runtimes.desktop_ui_native_runtime
  reason: The desktop runtime architecture and platform targets are defined at the ecosystem level, but implementation depth is still evolving.
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/platform_runtimes.spec.md
  covers:
    - ecosystem.platform_runtimes.widget_libraries_independent
    - ecosystem.platform_runtimes.native_surface_covers_iur
    - ecosystem.platform_runtimes.native_surface_usable_without_iur
    - ecosystem.platform_runtimes.iur_interpretation
    - ecosystem.platform_runtimes.web_ui_runtime_split
    - ecosystem.platform_runtimes.live_ui_runtime
    - ecosystem.platform_runtimes.desktop_ui_targets
    - ecosystem.platform_runtimes.desktop_ui_native_runtime
```
