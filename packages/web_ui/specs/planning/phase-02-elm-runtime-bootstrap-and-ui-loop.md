# Phase 2 - Elm Runtime Bootstrap and UI Loop

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- Elm `Main.init`, `update`, `view`, `subscriptions`
- `Browser.Events`
- `Html.Events`
- `WebUi.Channel` websocket contract surface
- JS interop port bridge seam

## Relevant Assumptions / Defaults
- Elm runtime is the canonical UI Runtime Plane authority.
- UI updates must be deterministic for equivalent event sequences.
- JS interop remains optional and isolated behind explicit ports.

[x] 2 Phase 2 - Elm Runtime Bootstrap and UI Loop
  Implement the browser runtime baseline so Elm state, websocket events, and UI rendering remain deterministic and contract-aligned.

  [x] 2.1 Section - Elm Application Bootstrap
    Implement deterministic Elm app initialization and baseline model hydration.

    [x] 2.1.1 Task - Implement canonical Elm model and message baseline
      Establish typed `Model`/`Msg` structures for transport events and UI commands.

      [x] 2.1.1.1 Subtask - Implement initial model fields for connection state, runtime context, and view state.
      [x] 2.1.1.2 Subtask - Implement baseline message variants for websocket receive/error/pong.
      [x] 2.1.1.3 Subtask - Implement deterministic model defaults for first render.

    [x] 2.1.2 Task - Implement websocket bootstrap flow from Elm init
      Open websocket transport and negotiate runtime handshake from deterministic init commands.

      [x] 2.1.2.1 Subtask - Implement startup command to join canonical runtime topic.
      [x] 2.1.2.2 Subtask - Implement initial runtime ping with correlation metadata.
      [x] 2.1.2.3 Subtask - Implement join failure handling with typed UI-visible error state.

  [x] 2.2 Section - Elm Update Loop and Event Dispatch
    Implement message routing from widget interactions to canonical CloudEvent dispatch commands.

    [x] 2.2.1 Task - Implement outbound widget-event command pipeline
      Map Elm interaction messages into contract-compliant event send payloads.

      [x] 2.2.1.1 Subtask - Implement widget-event to CloudEvent payload shaping helpers.
      [x] 2.2.1.2 Subtask - Implement outbound command path for `runtime.event.send.v1`.
      [x] 2.2.1.3 Subtask - Implement local validation guardrails before outbound dispatch.

    [x] 2.2.2 Task - Implement inbound runtime event application path
      Decode inbound runtime payloads and apply deterministic state transitions.

      [x] 2.2.2.1 Subtask - Implement decode and dispatch for `runtime.event.recv.v1` payloads.
      [x] 2.2.2.2 Subtask - Implement typed failure branch for `runtime.event.error.v1` payloads.
      [x] 2.2.2.3 Subtask - Implement keepalive state updates from `runtime.event.pong.v1`.

  [x] 2.3 Section - JS Interop and Extension Isolation
    Implement optional JS bridge behavior without violating transport or runtime authority boundaries.

    [x] 2.3.1 Task - Implement explicit typed Elm ports for optional browser features
      Define minimal typed port interfaces for extension behaviors requiring JS APIs.

      [x] 2.3.1.1 Subtask - Implement outbound port commands for supported extension operations.
      [x] 2.3.1.2 Subtask - Implement inbound port subscriptions with decoder-based validation.
      [x] 2.3.1.3 Subtask - Implement typed fallback behavior when port data is invalid.

    [x] 2.3.2 Task - Implement extension-boundary guardrails
      Prevent extension code from becoming alternate state or domain authority.

      [x] 2.3.2.1 Subtask - Implement policy checks restricting extension-triggered runtime actions.
      [x] 2.3.2.2 Subtask - Implement explicit provenance tags for port-originated events.
      [x] 2.3.2.3 Subtask - Implement extension error telemetry hooks for observability contract parity.

  [x] 2.4 Section - Phase 2 Integration Tests
    Validate Elm bootstrap, update-loop determinism, and extension-boundary behavior end-to-end.

    [x] 2.4.1 Task - Elm runtime bootstrap scenarios
      Verify deterministic init, websocket join, and early lifecycle behavior.

      [x] 2.4.1.1 Subtask - Verify first render state is deterministic across repeated boots.
      [x] 2.4.1.2 Subtask - Verify websocket join and ping/pong handshake behavior.
      [x] 2.4.1.3 Subtask - Verify join failure paths produce typed UI error state.

    [x] 2.4.2 Task - Event-loop and extension scenarios
      Verify outbound/inbound event mapping and JS interop isolation constraints.

      [x] 2.4.2.1 Subtask - Verify widget interaction produces canonical outbound event payloads.
      [x] 2.4.2.2 Subtask - Verify inbound runtime events drive deterministic model transitions.
      [x] 2.4.2.3 Subtask - Verify invalid port payloads fail closed without state-authority leakage.
