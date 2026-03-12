# Phase 5 - Widget Event Contracts and Elm Bindings

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `specs/events/event_type_catalog.md`
- `specs/events/widget_event_matrix.md`
- `specs/events/elm_binding_examples.md`
- `WebUi.Channel` event dispatch interface

## Relevant Assumptions / Defaults
- Standard `unified.*` event types are compatibility baseline.
- Widget handlers require route-key compatibility fields for dispatch.
- Event envelopes must preserve correlation metadata.

[x] 5 Phase 5 - Widget Event Contracts and Elm Bindings
  Implement canonical widget event behavior so built-in widgets emit and consume consistent event types aligned with Elm bindings and runtime routing.

  [x] 5.1 Section - Canonical Event Type Adoption
    Implement standard event-type usage and payload-key requirements across widget surfaces.

    [x] 5.1.1 Task - Implement baseline standard event-type coverage
      Adopt the baseline standard event types across all applicable widget interactions.

      [x] 5.1.1.1 Subtask - Implement `unified.button.clicked` mappings for clickable actions.
      [x] 5.1.1.2 Subtask - Implement `unified.input.changed` and `unified.form.submitted` form interaction mappings.
      [x] 5.1.1.3 Subtask - Implement focus/blur and selection/toggle mappings for interaction state transitions.

    [x] 5.1.2 Task - Implement extended event-type coverage for complex widgets
      Adopt extended event types for charts, overlays, trees, splits, and viewport interactions.

      [x] 5.1.2.1 Subtask - Implement chart and canvas event mappings for point and pointer interactions.
      [x] 5.1.2.2 Subtask - Implement overlay, menu, tab, and tree event mappings.
      [x] 5.1.2.3 Subtask - Implement scroll, split, and viewport resize event mappings.

  [x] 5.2 Section - Widget Event Matrix Wiring
    Implement matrix-driven event behavior for each built-in widget ID.

    [x] 5.2.1 Task - Implement per-widget event-schema declarations from matrix mappings
      Bind each built-in widget descriptor to required and optional event types from the matrix.

      [x] 5.2.1.1 Subtask - Implement descriptor event schema fields for primitive widgets.
      [x] 5.2.1.2 Subtask - Implement descriptor event schema fields for composite widgets.
      [x] 5.2.1.3 Subtask - Implement explicit `None` interaction handling for non-interactive widgets.

    [x] 5.2.2 Task - Implement event payload route-key compatibility rules
      Ensure payloads include keys required for update-routing compatibility.

      [x] 5.2.2.1 Subtask - Implement click-route key population (`action`, `button_id`, `widget_id`, `id`).
      [x] 5.2.2.2 Subtask - Implement change-route key population (`input_id`, `field`, `action`, `id`).
      [x] 5.2.2.3 Subtask - Implement submit-route key population (`form_id`, `action`, `id`).

  [x] 5.3 Section - Elm Binding Implementation Paths
    Implement Elm bindings that produce canonical widget events using standard `Html.Events` and `Browser.Events` surfaces.

    [x] 5.3.1 Task - Implement Html event bindings for standard interactions
      Use `onClick`, `onInput`, `onSubmit`, `onFocus`, and `onBlur` for baseline mappings.

      [x] 5.3.1.1 Subtask - Implement typed message constructors for standard widget events.
      [x] 5.3.1.2 Subtask - Implement decoder-backed helpers for additional event payload keys.
      [x] 5.3.1.3 Subtask - Implement submit prevention semantics consistent with Elm defaults.

    [x] 5.3.2 Task - Implement Browser/global subscription bindings for advanced interactions
      Use global subscriptions for resize and dynamic interaction streams.

      [x] 5.3.2.1 Subtask - Implement `Browser.Events.onResize` mapping to `unified.viewport.resized`.
      [x] 5.3.2.2 Subtask - Implement keyboard/pointer subscription mappings for action and canvas events.
      [x] 5.3.2.3 Subtask - Implement deterministic subscription teardown and re-subscription behavior.

  [x] 5.4 Section - Phase 5 Integration Tests
    Validate widget event behavior and Elm bindings against canonical event catalog and matrix requirements.

    [x] 5.4.1 Task - Widget-event mapping integration scenarios
      Verify built-in widgets emit contract-compliant event types with required payload keys.

      [x] 5.4.1.1 Subtask - Verify each interactive built-in widget emits only mapped event types.
      [x] 5.4.1.2 Subtask - Verify required `data` keys exist for each emitted event type.
      [x] 5.4.1.3 Subtask - Verify route-key compatibility fields are present when available.

    [x] 5.4.2 Task - Elm binding and continuity integration scenarios
      Verify Elm handlers produce canonical events and preserve correlation metadata into dispatch.

      [x] 5.4.2.1 Subtask - Verify standard `Html.Events` bindings produce canonical event envelopes.
      [x] 5.4.2.2 Subtask - Verify global `Browser.Events` subscriptions produce canonical advanced events.
      [x] 5.4.2.3 Subtask - Verify correlation and request identifiers persist through widget event dispatch.
