# Phase 1 - Package Scaffold and SDL2 Runtime Backbone

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `DesktopUi`
- `DesktopUi.Runtime`
- `DesktopUi.Platform`
- `DesktopUi.Renderer`
- `DesktopUi.Transport`
- `DesktopUi.Reference`
- `DesktopUi.Info`
- `:sdl`

## Relevant Assumptions / Defaults
- `desktop_ui` remains a plain Mix library even while it defines a runtime loop
  and platform integration seams.
- Shared SDL2 runtime mechanics should stabilize before canonical `UnifiedIUR`
  rendering and boundary translation are layered in.
- Platform-specific callbacks and packaging concerns must remain bounded behind
  explicit module seams from the start.

[ ] 1 Phase 1 - Package Scaffold and SDL2 Runtime Backbone
  Implement the Mix package scaffold, shared SDL2 runtime backbone, platform
  adapter seams, and baseline reference surfaces that every later `desktop_ui`
  phase depends on.

[x] 1.1 Section - Mix Package and Namespace Scaffold
    Implement the baseline package structure, namespace layout, and library
    packaging rules required for `desktop_ui`.

    [x] 1.1.1 Task - Implement the baseline Mix and package library skeleton
      Establish `packages/desktop_ui` as a standard Elixir library with package
      metadata, docs configuration, SDL2 dependency policy, and `unified_iur`
      dependency wiring.

      [x] 1.1.1.1 Subtask - Create `packages/desktop_ui/mix.exs` with package metadata, docs configuration, SDL2-related dependencies, and `unified_iur` dependency wiring.
      [x] 1.1.1.2 Subtask - Create the top-level `DesktopUi` namespace module together with package-facing entry modules for native widgets, runtime access, platform integration, canonical rendering, transport, and tooling.
      [x] 1.1.1.3 Subtask - Create `lib/`, `test/`, native runtime support, and package guide directories aligned with the `desktop_ui` structure spec.

    [x] 1.1.2 Task - Implement package namespace and directory boundaries
      Separate native widget, shared runtime, platform integration, canonical
      rendering, transport translation, and artifact concerns so the package
      grows coherently.

      [x] 1.1.2.1 Subtask - Create dedicated module areas for native widgets, shared SDL2 runtime coordination, platform adapters, canonical IUR rendering, transport translation, artifact workflows, and tooling helpers.
      [x] 1.1.2.2 Subtask - Establish public naming conventions for runtime entry points, platform modules, native widget namespaces, and package-facing helper modules.
      [x] 1.1.2.3 Subtask - Prevent the package structure from taking ownership of authored DSL concerns or canonical IUR model definitions.

  [x] 1.2 Section - Shared SDL2 Runtime Backbone
    Implement the shared runtime model that later native widgets, canonical
    rendering, and platform adapters will reuse.

    [x] 1.2.1 Task - Implement runtime entrypoints and state boundaries
      Define the baseline SDL2 runtime surface for direct native screens and
      renderer-driven screens.

      [x] 1.2.1.1 Subtask - Create runtime modules for application start, window boot, render-loop state initialization, and shutdown handling.
      [x] 1.2.1.2 Subtask - Define authoritative runtime state boundaries for window registry, focus state, redraw scheduling, and screen realization.
      [x] 1.2.1.3 Subtask - Define package-local error handling and lifecycle behavior for invalid runtime state, missing widgets, and boot failures.

    [x] 1.2.2 Task - Implement shared SDL2 event-loop scaffolding
      Create the minimum shared runtime mechanics needed to coordinate redraws,
      input polling, and window lifecycle before full transport translation
      exists.

      [x] 1.2.2.1 Subtask - Create package-local modules for event polling, redraw requests, input dispatch scaffolding, and frame coordination.
      [x] 1.2.2.2 Subtask - Create bounded placeholders for focus changes, shortcut handling, and window lifecycle callbacks that later transport translation can reuse.
      [x] 1.2.2.3 Subtask - Define diagnostics for invalid event-loop state, unsupported callback payloads, and mismatched runtime initialization order.

  [x] 1.3 Section - Platform Integration Seams
    Implement explicit Windows, macOS, and Linux adapter seams so platform
    variation stays bounded behind the shared runtime.

    [x] 1.3.1 Task - Implement platform adapter entrypoints
      Define the baseline adapter modules and capability boundaries for the
      first-class desktop targets.

      [x] 1.3.1.1 Subtask - Create Windows, macOS, and Linux adapter modules that plug into the shared SDL2 runtime without redefining widget semantics.
      [x] 1.3.1.2 Subtask - Define capability contracts for windowing, menus, shortcuts, and platform notifications that may vary underneath one runtime model.
      [x] 1.3.1.3 Subtask - Keep the initial platform adapters focused on integration seams rather than full artifact packaging logic.

    [x] 1.3.2 Task - Implement bounded platform callback and capability wiring
      Define how target-specific callbacks and capabilities surface through the
      shared runtime without leaking platform divergence everywhere.

      [x] 1.3.2.1 Subtask - Define package-local callback contracts for platform lifecycle, file-open, focus, and window-management hooks.
      [x] 1.3.2.2 Subtask - Isolate target-specific capability lookups and fallback behavior behind adapter boundaries.
      [x] 1.3.2.3 Subtask - Add diagnostics for unsupported platform capabilities, invalid adapter registration, and mismatched callback payloads.

  [x] 1.4 Section - Native Widget and Reference Backbone
    Implement the native widget contract and package-facing reference surfaces
    that let maintainers inspect runtime capabilities before full renderer
    coverage exists.

    [x] 1.4.1 Task - Implement the baseline native widget behavior and registration model
      Define how native `desktop_ui` widgets are declared, composed, and
      registered across the shared runtime.

      [x] 1.4.1.1 Subtask - Create the package-level native widget behavior or contract used by direct-use `desktop_ui` widgets.
      [x] 1.4.1.2 Subtask - Define common widget metadata, focus, slot, and style contracts shared by later widget families.
      [x] 1.4.1.3 Subtask - Keep the initial widget contract renderer-native and free of canonical IUR-specific branching.

    [x] 1.4.2 Task - Implement package reference and inspection summaries
      Provide lightweight introspection that summarizes declared widget
      families, runtime capabilities, platform seams, and validation state.

      [x] 1.4.2.1 Subtask - Implement reference helpers that list native widget families, runtime modules, platform adapters, and transport integration points as they are added.
      [x] 1.4.2.2 Subtask - Implement reference surfaces that report direct-native versus canonical-renderer package responsibilities across the shared runtime and adapter split.
      [x] 1.4.2.3 Subtask - Implement inspection helpers that expose SDL2 assumptions, platform seams, and package validation state.

  [ ] 1.5 Section - Phase 1 Integration Tests
    Validate package bootstrap, shared-runtime wiring, platform seams, native
    widget registration, and reference surfaces end to end.

    [ ] 1.5.1 Task - Package and runtime backbone integration scenarios
      Verify the package loads as a desktop runtime library and that minimal
      native screens boot through the shared SDL2 backbone.

      [ ] 1.5.1.1 Subtask - Verify the package compiles and exposes runtime, platform, and renderer entrypoints without taking over application startup.
      [ ] 1.5.1.2 Subtask - Verify a minimal native screen can boot, register a window, and render through the package backbone.
      [ ] 1.5.1.3 Subtask - Verify malformed widget declarations, invalid runtime boot data, or broken platform adapter registration fail with deterministic diagnostics.

    [ ] 1.5.2 Task - Reference and platform seam integration scenarios
      Verify package reference helpers remain usable before canonical renderer
      coverage is added.

      [ ] 1.5.2.1 Subtask - Verify reference helpers report widget families, runtime modules, and platform boundaries without renderer dependencies.
      [ ] 1.5.2.2 Subtask - Verify inspection surfaces expose SDL2 assumptions, adapter entry points, and validation state.
      [ ] 1.5.2.3 Subtask - Verify shared-runtime semantics remain visible through package-facing helper APIs even while platform-specific seams exist.
