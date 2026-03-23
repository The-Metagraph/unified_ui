# Phase 1 - Package Scaffold and Phoenix-Elm Runtime Backbone

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `ElmUi`
- `ElmUi.Server`
- `ElmUi.Frontend`
- `ElmUi.Runtime`
- `ElmUi.Reference`
- `ElmUi.Info`
- `Phoenix.Component`
- `Phoenix.Channel`

## Relevant Assumptions / Defaults
- `elm_ui` is a runtime library and should adopt the Phoenix server plus Elm frontend split explicitly in the package backbone.
- The package must remain usable as a plain Mix library while still establishing clear server, frontend, renderer, and transport entry points.
- Runtime split boundaries, browser bootstrapping, and native widget module seams must stabilize before canonical `UnifiedIUR` rendering is layered in.

[ ] 1 Phase 1 - Package Scaffold and Phoenix-Elm Runtime Backbone
  Implement the Mix package scaffold, split runtime backbone, native widget boundaries, and baseline reference surfaces that every later `elm_ui` phase depends on.

  [ ] 1.1 Section - Mix Package and Namespace Scaffold
    Implement the baseline package structure, namespace layout, and library packaging rules required for `elm_ui`.

    [ ] 1.1.1 Task - Implement the baseline Mix and package library skeleton
      Establish `packages/elm_ui` as a standard Elixir library with package metadata, docs configuration, Phoenix dependency policy, frontend asset layout, and `unified_iur` dependency wiring.

      [ ] 1.1.1.1 Subtask - Create `packages/elm_ui/mix.exs` with package metadata, docs configuration, Phoenix-related dependencies, frontend asset policy, and `unified_iur` dependency wiring.
      [ ] 1.1.1.2 Subtask - Create the top-level `ElmUi` namespace module together with package-facing entry modules for native widgets, server runtime access, frontend runtime access, canonical rendering, and tooling.
      [ ] 1.1.1.3 Subtask - Create `lib/`, `test/`, frontend asset, and package guide directories aligned with the `elm_ui` structure spec.

    [ ] 1.1.2 Task - Implement package namespace and directory boundaries
      Separate native widget, server runtime, frontend runtime, renderer, transport, and tooling concerns so the package grows coherently.

      [ ] 1.1.2.1 Subtask - Create dedicated module areas for native widgets, Phoenix runtime coordination, Elm-facing runtime coordination, canonical IUR rendering, transport translation, and tooling helpers.
      [ ] 1.1.2.2 Subtask - Establish public naming conventions for native widget namespaces, server entry points, frontend bridge modules, and package-facing helper modules.
      [ ] 1.1.2.3 Subtask - Prevent the package structure from taking ownership of authored DSL concerns or canonical IUR model definitions.

  [ ] 1.2 Section - Phoenix Server Runtime Backbone
    Implement the authoritative Phoenix-side runtime model that later event translation and canonical rendering will reuse.

    [ ] 1.2.1 Task - Implement server runtime entrypoints and state boundaries
      Define the baseline server runtime surface for direct native screens and renderer-driven screens.

      [ ] 1.2.1.1 Subtask - Create server runtime modules for screen mount, state initialization, update handling, and render orchestration.
      [ ] 1.2.1.2 Subtask - Define authoritative server-side state boundaries and where frontend synchronization may later plug in.
      [ ] 1.2.1.3 Subtask - Define package-local error handling and lifecycle behavior for invalid runtime state, missing widgets, and mount failures.

    [ ] 1.2.2 Task - Implement server-side browser coordination scaffolding
      Create the minimum server-side coordination model needed to drive an Elm frontend without collapsing runtime authority into the browser.

      [ ] 1.2.2.1 Subtask - Create package-local server modules for view-state generation, event routing, and frontend synchronization boundaries.
      [ ] 1.2.2.2 Subtask - Create bounded channel or message-envelope placeholders for future browser event delivery and runtime updates.
      [ ] 1.2.2.3 Subtask - Define diagnostics for invalid route wiring, unsupported frontend messages, and mismatched runtime state shape.

  [ ] 1.3 Section - Elm Frontend Runtime Backbone
    Implement the baseline frontend runtime model that later native widget families and canonical rendering will extend.

    [ ] 1.3.1 Task - Implement frontend runtime entrypoints and boot process
      Define how the package boots Elm assets, receives server-provided state, and renders the first browser-facing runtime shell.

      [ ] 1.3.1.1 Subtask - Create frontend entry modules and asset scaffolding for Elm runtime startup and browser mounting.
      [ ] 1.3.1.2 Subtask - Define the initial frontend model, message loop, and view bootstrap contract expected from the Phoenix side.
      [ ] 1.3.1.3 Subtask - Keep the initial frontend runtime focused on rendering and bounded local state rather than canonical event authorship.

    [ ] 1.3.2 Task - Implement baseline frontend bridge boundaries
      Define the browser bridge boundary for state hydration, server updates, and outgoing interaction messages.

      [ ] 1.3.2.1 Subtask - Define the browser-side state hydration and update contract that the server runtime will send to Elm.
      [ ] 1.3.2.2 Subtask - Define the initial message envelope for sending native browser interactions back toward the server runtime.
      [ ] 1.3.2.3 Subtask - Add diagnostics for malformed hydration payloads, unsupported messages, and invalid runtime boot order.

  [ ] 1.4 Section - Native Widget and Reference Backbone
    Implement the native widget contract and package-facing reference surfaces that let maintainers inspect runtime capabilities before full renderer coverage exists.

    [ ] 1.4.1 Task - Implement the baseline native widget behavior and registration model
      Define how native `elm_ui` widgets are declared, composed, and registered across the server and frontend runtimes.

      [ ] 1.4.1.1 Subtask - Create the package-level native widget behavior or contract used by direct-use `elm_ui` widgets.
      [ ] 1.4.1.2 Subtask - Define common widget metadata, state, slot, and style contracts shared by later widget families.
      [ ] 1.4.1.3 Subtask - Keep the initial widget contract renderer-native and free of canonical IUR-specific branching.

    [ ] 1.4.2 Task - Implement package reference and inspection summaries
      Provide lightweight introspection that summarizes declared widget families, runtime capabilities, and validation state.

      [ ] 1.4.2.1 Subtask - Implement reference helpers that list native widget families, runtime modules, and transport integration points as they are added.
      [ ] 1.4.2.2 Subtask - Implement reference surfaces that report direct-native versus canonical-renderer package responsibilities across the server and frontend split.
      [ ] 1.4.2.3 Subtask - Implement inspection helpers that expose runtime assumptions, browser bridge boundaries, and package validation state.

  [ ] 1.5 Section - Phase 1 Integration Tests
    Validate package bootstrap, split-runtime wiring, native widget registration, and reference surfaces end to end.

    [ ] 1.5.1 Task - Package and runtime backbone integration scenarios
      Verify the package loads as a web runtime library and that minimal native screens render through the Phoenix and Elm backbones.

      [ ] 1.5.1.1 Subtask - Verify the package compiles and exposes Phoenix-side and Elm-side entrypoints without taking over application startup.
      [ ] 1.5.1.2 Subtask - Verify a minimal native screen can mount, hydrate frontend state, and render through the package backbone.
      [ ] 1.5.1.3 Subtask - Verify malformed widget declarations, hydration payloads, or runtime wiring fail with deterministic diagnostics.

    [ ] 1.5.2 Task - Reference and inspection integration scenarios
      Verify package reference helpers remain usable before canonical renderer coverage is added.

      [ ] 1.5.2.1 Subtask - Verify reference helpers report widget families and split-runtime boundaries without renderer dependencies.
      [ ] 1.5.2.2 Subtask - Verify inspection surfaces expose runtime assumptions, bridge entry points, and validation state.
      [ ] 1.5.2.3 Subtask - Verify server-authoritative runtime assumptions remain visible through package-facing helper APIs.
