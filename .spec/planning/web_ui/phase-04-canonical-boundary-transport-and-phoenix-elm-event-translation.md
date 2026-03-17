# Phase 4 - Canonical Boundary Transport and Phoenix-Elm Event Translation

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `WebUi.Transport`
- `WebUi.Server`
- `WebUi.Frontend`
- `WebUi.Runtime`
- `WebUi.Signals`
- `Jido.Signal`
- `Phoenix.Channel`
- `Phoenix.Socket`

## Relevant Assumptions / Defaults
- `web_ui` may use its own native Phoenix-and-Elm interaction model locally, but canonical meaning must be preserved at package boundaries.
- The runtime split between server authority and frontend rendering must remain explicit even when interactions cross channels, sockets, or browser bridges.
- Canonical event translation should support both direct-native and canonical `UnifiedIUR` rendering paths through the same runtime model.

[ ] 4 Phase 4 - Canonical Boundary Transport and Phoenix-Elm Event Translation
  Implement the canonical boundary transport model, split-runtime event translation surfaces, and diagnostics that let `web_ui` speak ecosystem-wide canonical event meaning.

  [ ] 4.1 Section - Canonical Event Translation Backbone
    Implement the translation layer between native Phoenix-and-Elm interactions and canonical `Jido.Signal` meaning.

    [ ] 4.1.1 Task - Implement canonical signal translation primitives
      Define the package-local translation model for canonical event families, payload meaning, and runtime action mapping.

      [ ] 4.1.1.1 Subtask - Implement translation helpers for click, change, submit, open, close, navigation, selection, and command interaction families.
      [ ] 4.1.1.2 Subtask - Define how native Phoenix-and-Elm events map into canonical `Jido.Signal` values and CloudEvents-compatible envelopes.
      [ ] 4.1.1.3 Subtask - Define how canonical boundary events map back into server-side runtime actions, frontend updates, and widget behavior.

    [ ] 4.1.2 Task - Implement direct-native and canonical event convergence
      Ensure direct native interactions and canonical-rendered interactions share translation rules where package boundaries are crossed.

      [ ] 4.1.2.1 Subtask - Define which native interactions remain package-local and which cross the canonical boundary.
      [ ] 4.1.2.2 Subtask - Keep direct-native event handling ergonomic without weakening the canonical translation contract.
      [ ] 4.1.2.3 Subtask - Verify canonical translation does not require separate transport or runtime stacks for native and canonical screens.

  [ ] 4.2 Section - Server and Frontend Event Flow
    Implement the runtime event-handling flow that preserves Phoenix authority while supporting bounded Elm participation.

    [ ] 4.2.1 Task - Implement server-side transport orchestration
      Define how browser events, Phoenix handlers, and canonical boundary transport work together under one authoritative server runtime.

      [ ] 4.2.1.1 Subtask - Implement runtime event flow for native widget callbacks through Phoenix handlers and server-side state transitions.
      [ ] 4.2.1.2 Subtask - Implement channel, socket, or bridge helpers for canonical cross-package event exchange where needed.
      [ ] 4.2.1.3 Subtask - Ensure server-side routing preserves canonical intent and does not expose renderer-local event names externally.

    [ ] 4.2.2 Task - Implement bounded Elm-side event participation
      Keep Elm-side event handling useful but subordinate to server authority and canonical event translation.

      [ ] 4.2.2.1 Subtask - Implement frontend message handling for browser interactions that need local responsiveness before or alongside server coordination.
      [ ] 4.2.2.2 Subtask - Translate frontend-originated interaction data into package-local event flow without making the frontend the source of canonical truth.
      [ ] 4.2.2.3 Subtask - Add diagnostics for unsupported frontend payloads, leaked renderer-local keys, and invalid boundary envelopes.

  [ ] 4.3 Section - Actionable Boundary Diagnostics and Validation
    Implement diagnostics and validation rules that keep the transport layer honest across the split runtime.

    [ ] 4.3.1 Task - Implement canonical-boundary validation
      Reject transport behavior that would leak renderer-local semantics or undermine the server and frontend boundary contract.

      [ ] 4.3.1.1 Subtask - Implement validation for leaked renderer-local event names, frontend-only payload keys, and package-local envelope details.
      [ ] 4.3.1.2 Subtask - Implement validation for malformed canonical signal families, missing event context, and invalid payload mapping.
      [ ] 4.3.1.3 Subtask - Implement diagnostics that clearly distinguish native local handling failures from canonical-boundary translation failures.

  [ ] 4.4 Section - Maintained Boundary Examples
    Implement maintained examples that demonstrate direct-native and canonical boundary event translation.

    [ ] 4.4.1 Task - Implement transport-focused examples
      Provide reference examples that exercise direct native events, canonical-boundary translation, and mixed runtime flows across Phoenix and Elm.

      [ ] 4.4.1.1 Subtask - Create direct-native examples that keep events package-local while preserving canonical interaction family meaning.
      [ ] 4.4.1.2 Subtask - Create canonical-rendered examples that emit and consume boundary events through canonical translation.
      [ ] 4.4.1.3 Subtask - Create mixed examples that compare native and canonical event paths for the same workflow across the server and frontend split.

  [ ] 4.5 Section - Phase 4 Integration Tests
    Validate event translation, split-runtime participation, and canonical transport behavior end to end.

    [ ] 4.5.1 Task - Native and canonical event translation scenarios
      Verify event translation remains canonical where boundaries are crossed and ergonomic where interactions stay local.

      [ ] 4.5.1.1 Subtask - Verify direct-native interactions can remain local without compromising later canonical translation.
      [ ] 4.5.1.2 Subtask - Verify canonical boundary events use `Jido.Signal` and preserve family and intent meaning.
      [ ] 4.5.1.3 Subtask - Verify invalid boundary leakage fails with actionable diagnostics.

    [ ] 4.5.2 Task - Split-runtime event coordination scenarios
      Verify the frontend runtime participates in event flow without displacing server authority.

      [ ] 4.5.2.1 Subtask - Verify server-side runtime state remains authoritative across translated events and frontend updates.
      [ ] 4.5.2.2 Subtask - Verify bounded Elm-side behavior contributes browser responsiveness rather than canonical runtime decisions.
      [ ] 4.5.2.3 Subtask - Verify canonical event handling is consistent across direct-native and canonical-rendered screens.
