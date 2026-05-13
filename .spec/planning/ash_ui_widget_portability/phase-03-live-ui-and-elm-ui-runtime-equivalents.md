# Phase 3 - LiveUi and ElmUi Runtime Equivalents

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `LiveUi`
- `LiveUi.Component`
- `LiveUi.Renderer`
- `LiveUi.Runtime`
- `ElmUi`
- `ElmUi.Renderer`
- `ElmUi.ServerRuntime`
- Elm frontend runtime modules
- shared `UnifiedIUR` promoted widget fixtures

## Relevant Assumptions / Defaults
- Web runtimes may use host form lifecycles, route integration, browser
  events, and frontend state internally, but those details remain runtime
  concerns.
- Native runtime surfaces remain usable without first loading canonical IUR.
- Canonical IUR rendering must preserve promoted widget and repeated
  collection meaning even when native implementation details differ.

[ ] 3 Phase 3 - LiveUi and ElmUi Runtime Equivalents
  Implement native web-runtime equivalents and IUR rendering support for the
  promoted widgets and repeated collection construct in `live_ui` and
  `elm_ui`.

  [ ] 3.1 Section - LiveUi Native and IUR Runtime Support
    Add LiveView-native widgets and canonical rendering paths for the promoted
    surface.

    [ ] 3.1.1 Task - Implement LiveUi semantic and workflow widget equivalents
      Provide direct native `live_ui` widgets for the promoted canonical
      surface while preserving LiveView ergonomics.

      [ ] 3.1.1.1 Subtask - Add native LiveView components or helpers for semantic micro widgets, workflow/document widgets, slide-over panels, syntax-highlighted code blocks, and chat composers.
      [ ] 3.1.1.2 Subtask - Preserve accessible labels, keyboard behavior, focus management, state transitions, and event bindings using LiveView-native conventions.
      [ ] 3.1.1.3 Subtask - Add native `live_ui` tests for component rendering, event emission, slot handling, and style-token application.

    [ ] 3.1.2 Task - Implement LiveUi IUR rendering and host form shell support
      Make canonical IUR promoted widgets render through the same runtime
      behaviors as the native surface.

      [ ] 3.1.2.1 Subtask - Extend the `live_ui` IUR renderer to consume every promoted canonical widget node and repeated collection construct.
      [ ] 3.1.2.2 Subtask - Map host-owned form shell IUR data onto LiveView form lifecycle integration without reintroducing Phoenix-specific fields into canonical data.
      [ ] 3.1.2.3 Subtask - Add rendering tests that compare native widget output and IUR-rendered output for equivalent semantic cases.

  [ ] 3.2 Section - ElmUi Native and IUR Runtime Support
    Add Phoenix-plus-Elm runtime widgets and canonical rendering paths for the
    promoted surface.

    [ ] 3.2.1 Task - Implement ElmUi semantic and workflow widget equivalents
      Provide direct native `elm_ui` widgets across the server and frontend
      runtime split.

      [ ] 3.2.1.1 Subtask - Add server-side widget descriptors and Elm frontend renderers for semantic micro widgets, workflow/document widgets, slide-over panels, syntax-highlighted code blocks, and chat composers.
      [ ] 3.2.1.2 Subtask - Preserve accessible labels, keyboard behavior, local frontend state, server-authoritative state, and event bridge semantics.
      [ ] 3.2.1.3 Subtask - Add tests for server descriptors, frontend rendering, event bridge payloads, and deterministic serialization.

    [ ] 3.2.2 Task - Implement ElmUi IUR rendering and host form shell support
      Make canonical IUR promoted widgets render through the split Phoenix and
      Elm runtime model.

      [ ] 3.2.2.1 Subtask - Extend the `elm_ui` IUR renderer to consume every promoted canonical widget node and repeated collection construct.
      [ ] 3.2.2.2 Subtask - Map host-owned form shell IUR data onto the ElmUi server/frontend form lifecycle without leaking canonical Phoenix or Ash assumptions.
      [ ] 3.2.2.3 Subtask - Add parity tests that compare direct native descriptors and IUR-rendered descriptors for equivalent widget scenarios.

  [ ] 3.3 Section - Web Runtime Repeated Collection and Interaction Semantics
    Implement repeated collection realization and row-scope interaction
    semantics consistently across both web runtimes.

    [ ] 3.3.1 Task - Implement repeated collection rendering for LiveUi and ElmUi
      Render canonical repeated collection constructs through native web
      runtime composition.

      [ ] 3.3.1.1 Subtask - Render list data with stable item identity, row aliases, empty states, and child templates in `live_ui`.
      [ ] 3.3.1.2 Subtask - Render list data with stable item identity, row aliases, empty states, and child templates in `elm_ui`.
      [ ] 3.3.1.3 Subtask - Add tests for insert, update, remove, empty state, and nested promoted widget scenarios.

    [ ] 3.3.2 Task - Preserve row-scope interaction payloads across web runtimes
      Ensure user interactions inside repeated rows carry canonical row-scope
      meaning at the package boundary.

      [ ] 3.3.2.1 Subtask - Verify LiveView events emitted inside repeated rows include the canonical row-scope payload mapping.
      [ ] 3.3.2.2 Subtask - Verify Elm frontend events emitted inside repeated rows cross the server bridge with the canonical row-scope payload mapping.
      [ ] 3.3.2.3 Subtask - Add diagnostics for missing keys, stale row references, and unsupported row-scope bindings.

  [ ] 3.4 Section - Phase 3 Integration Tests
    Validate the promoted web-runtime surface from direct native use through
    canonical IUR rendering and interaction handling.

    [ ] 3.4.1 Task - Web runtime widget parity scenarios
      Verify `live_ui` and `elm_ui` expose usable native widgets and matching
      canonical IUR renderer paths.

      [ ] 3.4.1.1 Subtask - Verify each promoted widget renders through native `live_ui`, native `elm_ui`, and each runtime's IUR renderer.
      [ ] 3.4.1.2 Subtask - Verify host-owned form shells submit, validate, and surface errors through runtime-owned lifecycle behavior.
      [ ] 3.4.1.3 Subtask - Verify accessibility, focus, keyboard, and interaction behavior for slide-over panels, disclosure, segmented controls, and chat composer.

    [ ] 3.4.2 Task - Web repeated collection integration scenarios
      Verify repeated collection rendering and row-scope events behave
      consistently across the two web runtimes.

      [ ] 3.4.2.1 Subtask - Verify repeated collection fixtures render stable rows, empty states, nested widgets, and updates in both web runtimes.
      [ ] 3.4.2.2 Subtask - Verify row-level interactions emit canonical payloads without runtime-local callback leakage.
      [ ] 3.4.2.3 Subtask - Verify native and IUR-rendered versions of the same repeated collection remain reviewably equivalent.
