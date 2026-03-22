# Phase 1 - Package Scaffold and TermUI Runtime Adapter Backbone

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `TerminalUi`
- `TerminalUi.Runtime`
- `TerminalUi.Backend`
- `TerminalUi.Capabilities`
- `TerminalUi.Renderer`
- `TerminalUi.Transport`
- `TerminalUi.Reference`
- `TerminalUi.Info`
- `TermUI.Runtime`

## Relevant Assumptions / Defaults
- `terminal_ui` remains a plain Mix library even while it defines a runtime
  loop and backend adapter seams.
- Shared `term_ui` runtime mechanics should stabilize before canonical
  `UnifiedIUR` rendering and boundary translation are layered in.
- Backend-specific callbacks and capability concerns must remain bounded behind
  explicit module seams from the start.

[x] 1 Phase 1 - Package Scaffold and TermUI Runtime Adapter Backbone
  Implement the Mix package scaffold, shared `term_ui` runtime adapter
  backbone, backend and capability seams, and baseline reference surfaces that
  every later `terminal_ui` phase depends on.

[x] 1.1 Section - Mix Package and Namespace Scaffold
    Implement the baseline package structure, namespace layout, and library
    packaging rules required for `terminal_ui`.

    [x] 1.1.1 Task - Implement the baseline Mix and package library skeleton
      Establish `packages/terminal_ui` as a standard Elixir library with
      package metadata, docs configuration, `term_ui` dependency policy, and
      `unified_iur` dependency wiring.

      [x] 1.1.1.1 Subtask - Create `packages/terminal_ui/mix.exs` with package metadata, docs configuration, `term_ui` dependency wiring, and `unified_iur` dependency wiring.
      [x] 1.1.1.2 Subtask - Create the top-level `TerminalUi` namespace module together with package-facing entry modules for native widgets, runtime access, backend and capability access, canonical rendering, transport, and tooling.
      [x] 1.1.1.3 Subtask - Create `lib/`, `test/`, runtime adapter support, and package guide directories aligned with the `terminal_ui` structure spec.

    [x] 1.1.2 Task - Implement package namespace and directory boundaries
      Separate native widget, shared runtime adapter, capability, canonical
      rendering, transport translation, and tooling concerns so the package
      grows coherently.

      [x] 1.1.2.1 Subtask - Create dedicated module areas for native widgets, shared `term_ui` runtime coordination, backend and capability adapters, canonical IUR rendering, transport translation, and tooling helpers.
      [x] 1.1.2.2 Subtask - Establish public naming conventions for runtime entry points, backend modules, native widget namespaces, and package-facing helper modules.
      [x] 1.1.2.3 Subtask - Prevent the package structure from taking ownership of authored DSL concerns or canonical IUR model definitions.

  [x] 1.2 Section - Shared TermUI Runtime Adapter Backbone
    Implement the shared runtime model that later native widgets, canonical
    rendering, and capability-aware behavior will reuse.

    [x] 1.2.1 Task - Implement runtime entrypoints and state boundaries
      Define the baseline terminal runtime surface for direct native screens
      and renderer-driven screens.

      [x] 1.2.1.1 Subtask - Create runtime modules for application start, runtime boot, terminal initialization, and shutdown handling.
      [x] 1.2.1.2 Subtask - Define authoritative runtime state boundaries for backend mode, focus state, redraw scheduling, capability snapshots, and screen realization.
      [x] 1.2.1.3 Subtask - Define package-local error handling and lifecycle behavior for invalid runtime state, missing widgets, and boot failures.

    [x] 1.2.2 Task - Implement shared terminal event-loop scaffolding
      Create the minimum shared runtime mechanics needed to coordinate redraws,
      input polling, and terminal lifecycle before full transport translation
      exists.

      [x] 1.2.2.1 Subtask - Create package-local modules for event polling, redraw requests, input dispatch scaffolding, and frame coordination.
      [x] 1.2.2.2 Subtask - Create bounded placeholders for focus changes, paste handling, resize callbacks, and mouse fallback behavior that later transport translation can reuse.
      [x] 1.2.2.3 Subtask - Define diagnostics for invalid event-loop state, unsupported callback payloads, and mismatched runtime initialization order.

  [x] 1.3 Section - Backend and Capability Seams
    Implement explicit richer and limited backend seams so terminal variation
    stays bounded behind the shared runtime.

    [x] 1.3.1 Task - Implement backend adapter entrypoints
      Define the baseline adapter modules and capability boundaries for richer
      raw-mode and TTY-compatible terminal execution.

      [x] 1.3.1.1 Subtask - Create raw-mode and TTY-compatible adapter modules that plug into the shared `term_ui` runtime without redefining widget semantics.
      [x] 1.3.1.2 Subtask - Define capability contracts for colors, Unicode, mouse, paste, resize, and terminal presence that may vary underneath one runtime model.
      [x] 1.3.1.3 Subtask - Keep the initial backend adapters focused on integration seams rather than full transport and degradation logic.

    [x] 1.3.2 Task - Implement bounded backend callback and capability wiring
      Define how backend-specific callbacks and capabilities surface through the
      shared runtime without leaking backend divergence everywhere.

      [x] 1.3.2.1 Subtask - Define package-local callback contracts for terminal lifecycle, resize, focus, paste, and backend boot hooks.
      [x] 1.3.2.2 Subtask - Isolate capability lookups, fallback behavior, and backend selection rules behind adapter boundaries.
      [x] 1.3.2.3 Subtask - Add diagnostics for unsupported capabilities, invalid adapter registration, and mismatched callback payloads.

  [x] 1.4 Section - Native Widget and Reference Backbone
    Implement the native widget contract and package-facing reference surfaces
    that let maintainers inspect runtime capabilities before full renderer
    coverage exists.

    [x] 1.4.1 Task - Implement the baseline native widget behavior and registration model
      Define how native `terminal_ui` widgets are declared, composed, and
      registered across the shared runtime.

      [x] 1.4.1.1 Subtask - Create the package-level native widget behavior or contract used by direct-use `terminal_ui` widgets.
      [x] 1.4.1.2 Subtask - Define common widget metadata, focus, slot, style, and degradation contracts shared by later widget families.
      [x] 1.4.1.3 Subtask - Keep the initial widget contract renderer-native and free of canonical IUR-specific branching.

    [x] 1.4.2 Task - Implement package reference and inspection summaries
      Provide lightweight introspection that summarizes declared widget
      families, runtime capabilities, backend seams, and validation state.

      [x] 1.4.2.1 Subtask - Implement reference helpers that list native widget families, runtime modules, backend adapters, and transport integration points as they are added.
      [x] 1.4.2.2 Subtask - Implement reference surfaces that report direct-native versus canonical-renderer package responsibilities across the shared runtime and adapter split.
      [x] 1.4.2.3 Subtask - Implement inspection helpers that expose capability assumptions, backend seams, and package validation state.

  [x] 1.5 Section - Phase 1 Integration Tests
    Validate package bootstrap, shared-runtime wiring, backend seams, native
    widget registration, and reference surfaces end to end.

    [x] 1.5.1 Task - Package and runtime backbone integration scenarios
      Verify the package loads as a terminal runtime library and that minimal
      native screens boot through the shared `term_ui` backbone.

      [x] 1.5.1.1 Subtask - Verify the package compiles and exposes runtime, capability, backend, and renderer entrypoints without taking over application startup.
      [x] 1.5.1.2 Subtask - Verify a minimal native screen can boot, register a runtime root, and render through the package backbone.
      [x] 1.5.1.3 Subtask - Verify malformed widget declarations, invalid runtime boot data, or broken backend adapter registration fail with deterministic diagnostics.

    [x] 1.5.2 Task - Reference and capability seam integration scenarios
      Verify package reference helpers remain usable before canonical renderer
      coverage is added.

      [x] 1.5.2.1 Subtask - Verify reference helpers report widget families, runtime modules, and backend boundaries without renderer dependencies.
      [x] 1.5.2.2 Subtask - Verify inspection surfaces expose capability assumptions, adapter entry points, and validation state.
      [x] 1.5.2.3 Subtask - Verify shared-runtime semantics remain visible through package-facing helper APIs even while capability-specific seams exist.
