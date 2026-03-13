# Platform Runtimes

This subject defines the renderer and widget-library responsibilities for the ecosystem runtime packages.

```spec-meta
id: ecosystem.platform_runtimes
kind: architecture
status: active
summary: Architecture contract for `web_ui`, `live_ui`, and `desktop_ui` as native widget libraries that also consume canonical IUR.
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

- id: ecosystem.platform_runtimes.iur_interpretation
  statement: Each widget library shall be able to interpret canonical `unified_iur` input and render it using its own native widget system.
  priority: must
  stability: stable

- id: ecosystem.platform_runtimes.web_ui_runtime_split
  statement: `web_ui` shall use Phoenix for server-side runtime representation and Elm for client-side rendering and local state while preserving canonical IUR and event semantics across the boundary.
  priority: must
  stability: stable

- id: ecosystem.platform_runtimes.live_ui_runtime
  statement: `live_ui` shall use Phoenix LiveView components with JavaScript hooks only where necessary to bridge canonical signals and local widget behavior.
  priority: must
  stability: stable

- id: ecosystem.platform_runtimes.desktop_ui_targets
  statement: `desktop_ui` shall target Windows, macOS, and Linux using an SDL2-based desktop runtime with its own native widget set.
  priority: must
  stability: stable

- id: ecosystem.platform_runtimes.desktop_ui_internal_signal_model
  statement: `desktop_ui` shall use canonical Jido.Signal and CloudEvents-compatible semantics inside its own runtime, even when the communication does not leave the desktop package boundary.
  priority: must
  stability: stable
```

## Exceptions

```spec-exceptions
- id: ecosystem.platform_runtimes.desktop_runtime_evolving
  covers:
    - ecosystem.platform_runtimes.desktop_ui_targets
    - ecosystem.platform_runtimes.desktop_ui_internal_signal_model
  reason: The desktop runtime architecture and platform targets are defined at the ecosystem level, but implementation depth is still evolving.
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/platform_runtimes.spec.md
  covers:
    - ecosystem.platform_runtimes.widget_libraries_independent
    - ecosystem.platform_runtimes.iur_interpretation
    - ecosystem.platform_runtimes.web_ui_runtime_split
    - ecosystem.platform_runtimes.live_ui_runtime
    - ecosystem.platform_runtimes.desktop_ui_targets
    - ecosystem.platform_runtimes.desktop_ui_internal_signal_model
```
