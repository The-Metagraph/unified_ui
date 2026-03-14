# DesktopUi Runtime

This subject defines the target runtime behavior of `desktop_ui` as a
multiplatform SDL2-based desktop library.

## Related General Specs

- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [DesktopUi Package](./package.spec.md)
- [DesktopUi Native Widgets](./native_widgets.spec.md)
- [DesktopUi Transport](./transport.spec.md)

```spec-meta
id: desktop_ui.runtime
kind: runtime
status: active
summary: Target multiplatform desktop runtime contract for `desktop_ui`, including SDL2-based rendering and input coordination across Windows, macOS, and Linux.
surface:
  - packages/desktop_ui
  - .spec/specs/desktop_ui/runtime.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: desktop_ui.runtime.sdl2_foundation
  statement: The desktop runtime shall use SDL2 as the shared rendering and input foundation across supported desktop targets while allowing platform integration layers to supply target-specific behavior where needed.
  priority: must
  stability: stable

- id: desktop_ui.runtime.shared_runtime_across_targets
  statement: The package shall maintain one coherent desktop runtime model across Windows, macOS, and Linux even when platform integration details differ.
  priority: must
  stability: stable

- id: desktop_ui.runtime.native_and_iur_entrypoints_share_runtime
  statement: The same runtime architecture shall support both direct native `desktop_ui` usage and canonical IUR rendering so the package does not split into unrelated runtime models.
  priority: must
  stability: stable

- id: desktop_ui.runtime.window_lifecycle_and_input
  statement: The runtime shall coordinate window lifecycle, desktop input, focus, redraw scheduling, and platform callbacks in a way that preserves canonical desktop UI meaning across supported targets.
  priority: must
  stability: stable

- id: desktop_ui.runtime.platform_variation_bounded
  statement: Platform-specific runtime behavior may vary where operating-system integration requires it, but those variations shall remain bounded behind the shared `desktop_ui` runtime model.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: desktop_ui.runtime_run_same_screen_on_multiple_targets
  given: The same native or canonical-IUR-driven screen is launched on Windows, macOS, and Linux
  when: `desktop_ui` runs the screen
  then: The package preserves one runtime model and one canonical UI meaning while allowing target-specific integration details underneath
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/desktop_ui/runtime.spec.md
  covers:
    - desktop_ui.runtime.sdl2_foundation
    - desktop_ui.runtime.shared_runtime_across_targets
    - desktop_ui.runtime.native_and_iur_entrypoints_share_runtime
    - desktop_ui.runtime.window_lifecycle_and_input
    - desktop_ui.runtime.platform_variation_bounded
    - desktop_ui.runtime_run_same_screen_on_multiple_targets
```
