# Phase 1 - Package Scaffold and LiveView Runtime Backbone

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `LiveUi`
- `LiveUi.Component`
- `LiveUi.Runtime`
- `LiveUi.Reference`
- `LiveUi.Info`
- `Phoenix.LiveComponent`
- `Phoenix.LiveView`

## Relevant Assumptions / Defaults
- `live_ui` is a runtime library and should adopt Phoenix LiveView explicitly in the package backbone.
- The package must remain usable as a plain Mix library while still establishing clear runtime entry points.
- Native widget/component boundaries and server-authoritative runtime shape must stabilize before canonical `UnifiedIUR` rendering is layered in.

[ ] 1 Phase 1 - Package Scaffold and LiveView Runtime Backbone
  Implement the Mix package scaffold, LiveView runtime backbone, native component boundaries, and baseline reference surfaces that every later `live_ui` phase depends on.

  [ ] 1.1 Section - Mix Package and Namespace Scaffold
    Implement the baseline package structure, namespace layout, and library packaging rules required for `live_ui`.

    [ ] 1.1.1 Task - Implement the baseline Mix and Phoenix-facing library skeleton
      Establish `packages/live_ui` as a standard Elixir library with package metadata, Phoenix and LiveView dependency policy, and package docs entry points.

      [ ] 1.1.1.1 Subtask - Create `packages/live_ui/mix.exs` with package metadata, docs configuration, Phoenix and LiveView dependencies, and `unified_iur` dependency wiring.
      [ ] 1.1.1.2 Subtask - Create the top-level `LiveUi` namespace module together with package-facing entry modules for native widgets, runtime access, canonical rendering, and tooling.
      [ ] 1.1.1.3 Subtask - Create `lib/`, `test/`, asset-support, and package guide directories aligned with the `live_ui` structure spec.

    [ ] 1.1.2 Task - Implement package namespace and directory boundaries
      Separate native widget, runtime, renderer, transport, and tooling concerns so the package grows coherently.

      [ ] 1.1.2.1 Subtask - Create dedicated module areas for native widgets, runtime coordination, canonical IUR rendering, transport translation, and tooling helpers.
      [ ] 1.1.2.2 Subtask - Establish public naming conventions for native widget namespaces, runtime entry points, and package-facing helper modules.
      [ ] 1.1.2.3 Subtask - Prevent the package structure from taking ownership of authored DSL concerns or canonical IUR model definitions.

  [ ] 1.2 Section - Native Widget and LiveComponent Backbone
    Implement the native component model that later widget families will extend.

    [ ] 1.2.1 Task - Implement the baseline native widget behavior and component entrypoints
      Define how native `live_ui` widgets are declared, composed, and rendered through LiveView-native component boundaries.

      [ ] 1.2.1.1 Subtask - Create the package-level native widget behavior or contract used by direct-use `live_ui` widgets.
      [ ] 1.2.1.2 Subtask - Create baseline LiveComponent or function-component entrypoints for native widget rendering.
      [ ] 1.2.1.3 Subtask - Define a common assigns and metadata contract that later native widget families will share.

    [ ] 1.2.2 Task - Implement native composition and runtime mounting scaffolding
      Define the baseline composition model for assembling native widgets into screens and subtrees.

      [ ] 1.2.2.1 Subtask - Create baseline screen, container, and slot composition helpers for LiveView-native usage.
      [ ] 1.2.2.2 Subtask - Define how runtime mount state, assigns initialization, and component lifecycle are organized.
      [ ] 1.2.2.3 Subtask - Keep the initial composition model renderer-native and free of canonical IUR-specific branching.

  [ ] 1.3 Section - Server-Authoritative Runtime Backbone
    Implement the server-led runtime model that later event translation and canonical rendering will reuse.

    [ ] 1.3.1 Task - Implement LiveView runtime entrypoints and state boundaries
      Define the baseline LiveView runtime surface for direct native screens and renderer-driven screens.

      [ ] 1.3.1.1 Subtask - Create runtime modules for screen mount, assigns state, update handling, and render orchestration.
      [ ] 1.3.1.2 Subtask - Define server-authoritative state boundaries and where browser-side hooks may later plug in.
      [ ] 1.3.1.3 Subtask - Define package-local error handling and lifecycle behavior for missing widgets, invalid state, and mount failures.

    [ ] 1.3.2 Task - Implement baseline event-handling and browser-bridge scaffolding
      Create the minimum event loop needed for native widget interaction without leaking canonical boundary transport details prematurely.

      [ ] 1.3.2.1 Subtask - Create package-local event handling for native widget callbacks through LiveView events and assigns updates.
      [ ] 1.3.2.2 Subtask - Create bounded browser-bridge placeholders for future hooks and channel translation without making them the runtime authority.
      [ ] 1.3.2.3 Subtask - Define compile-time or runtime diagnostics for invalid event routing and unsupported widget interaction wiring.

  [ ] 1.4 Section - Reference and Introspection Baseline
    Implement the package-facing reference surfaces that let maintainers inspect native runtime capabilities without full renderer coverage yet.

    [ ] 1.4.1 Task - Implement package reference surfaces
      Provide package helpers that report supported native widget categories, runtime entry points, and package structure boundaries.

      [ ] 1.4.1.1 Subtask - Implement reference helpers that list native widget families, runtime modules, and transport integration points as they are added.
      [ ] 1.4.1.2 Subtask - Implement reference surfaces that report direct-native versus canonical-renderer package responsibilities.
      [ ] 1.4.1.3 Subtask - Implement helpers that expose server-authoritative runtime assumptions and hook-boundary rules.

    [ ] 1.4.2 Task - Implement runtime inspection summaries
      Provide lightweight introspection that summarizes declared native widgets, runtime capabilities, and validation state.

      [ ] 1.4.2.1 Subtask - Implement module summaries for widget registration, runtime entry points, and package validation state.
      [ ] 1.4.2.2 Subtask - Implement inspection helpers that surface assigns contracts, mount defaults, and native widget metadata.
      [ ] 1.4.2.3 Subtask - Keep these inspection surfaces usable without requiring canonical IUR renderer coverage to exist yet.

  [ ] 1.5 Section - Phase 1 Integration Tests
    Validate package bootstrap, native component registration, runtime backbone behavior, and reference surfaces end to end.

    [ ] 1.5.1 Task - Package and runtime backbone integration scenarios
      Verify the package loads as a runtime library and that minimal native screens render through the LiveView backbone.

      [ ] 1.5.1.1 Subtask - Verify the package compiles and exposes LiveView-native entrypoints without taking over application startup.
      [ ] 1.5.1.2 Subtask - Verify a minimal native screen can mount, initialize assigns, and render through the package backbone.
      [ ] 1.5.1.3 Subtask - Verify malformed widget declarations or runtime wiring fail with deterministic diagnostics.

    [ ] 1.5.2 Task - Reference and inspection integration scenarios
      Verify package reference helpers remain usable before canonical renderer coverage is added.

      [ ] 1.5.2.1 Subtask - Verify reference helpers report native widget families and runtime boundaries without renderer dependencies.
      [ ] 1.5.2.2 Subtask - Verify runtime inspection surfaces expose mount defaults and package validation state.
      [ ] 1.5.2.3 Subtask - Verify server-authoritative runtime assumptions are visible through package-facing helper APIs.
