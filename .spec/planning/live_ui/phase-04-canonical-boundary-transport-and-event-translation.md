# Phase 4 - Canonical Boundary Transport and Event Translation

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `LiveUi.Transport`
- `LiveUi.Runtime`
- `LiveUi.Signals`
- `Jido.Signal`
- `Phoenix.LiveView`
- `Phoenix.Channel`

## Relevant Assumptions / Defaults
- `live_ui` may use native LiveView interaction behavior locally, but canonical meaning must be preserved at package boundaries.
- Server-authoritative behavior must remain primary even when browser hooks or channels participate in event flow.
- Canonical event translation should support both direct-native and canonical `UnifiedIUR` rendering paths through the same runtime model.

[x] 4 Phase 4 - Canonical Boundary Transport and Event Translation
  Implement the canonical boundary transport model, event translation surfaces, and diagnostics that let `live_ui` speak ecosystem-wide canonical event meaning.

  [x] 4.1 Section - Canonical Event Translation Backbone
    Implement the translation layer between native LiveView interactions and canonical `Jido.Signal` meaning.

    [x] 4.1.1 Task - Implement canonical signal translation primitives
      Define the package-local translation model for canonical event families and payload meaning.

      [x] 4.1.1.1 Subtask - Implement translation helpers for click, change, submit, open, navigation, and command interaction families.
      [x] 4.1.1.2 Subtask - Define how native LiveView events map into canonical `Jido.Signal` values and CloudEvents-compatible envelopes.
      [x] 4.1.1.3 Subtask - Define how canonical boundary events map back into native runtime actions and widget updates.

    [x] 4.1.2 Task - Implement direct-native and canonical event convergence
      Ensure direct native interactions and canonical-rendered interactions share translation rules where package boundaries are crossed.

      [x] 4.1.2.1 Subtask - Define which native interactions remain package-local and which cross the canonical boundary.
      [x] 4.1.2.2 Subtask - Keep direct-native event handling ergonomic without weakening the canonical translation contract.
      [x] 4.1.2.3 Subtask - Verify canonical translation does not require separate runtime stacks for native and canonical screens.

  [x] 4.2 Section - Runtime Event Flow and Channel Boundaries
    Implement the runtime event-handling flow that preserves server authority while supporting canonical transport.

    [x] 4.2.1 Task - Implement LiveView and channel event orchestration
      Define how browser events, LiveView callbacks, and channel transport work together under one server-authoritative runtime.

      [x] 4.2.1.1 Subtask - Implement runtime event flow for native widget callbacks through LiveView handlers.
      [x] 4.2.1.2 Subtask - Implement channel or boundary transport helpers for canonical cross-package event exchange where needed.
      [x] 4.2.1.3 Subtask - Ensure event routing preserves canonical intent and does not expose renderer-local event names externally.

    [x] 4.2.2 Task - Implement bounded browser-hook participation
      Keep browser hooks useful but subordinate to the LiveView runtime and canonical event model.

      [x] 4.2.2.1 Subtask - Implement hook integration only for browser behaviors that LiveView cannot handle adequately alone.
      [x] 4.2.2.2 Subtask - Translate hook-originated data into package-local event flow without making hooks the source of canonical truth.
      [x] 4.2.2.3 Subtask - Add diagnostics for unsupported hook payloads, leaked renderer-local keys, and invalid boundary envelopes.

  [x] 4.3 Section - Actionable Boundary Diagnostics and Validation
    Implement diagnostics and validation rules that keep the transport layer honest.

    [x] 4.3.1 Task - Implement canonical-boundary validation
      Reject transport behavior that would leak renderer-local semantics or undermine server authority.

      [x] 4.3.1.1 Subtask - Implement validation for leaked renderer-local event names and payload keys.
      [x] 4.3.1.2 Subtask - Implement validation for malformed canonical signal families, missing event context, and invalid payload mapping.
      [x] 4.3.1.3 Subtask - Implement diagnostics that clearly distinguish package-local native handling from canonical-boundary translation failures.

  [x] 4.4 Section - Maintained Boundary Examples
    Implement maintained examples that demonstrate direct-native and canonical boundary event translation.

    [x] 4.4.1 Task - Implement transport-focused examples
      Provide reference examples that exercise direct native events, canonical-boundary translation, and mixed runtime flows.

      [x] 4.4.1.1 Subtask - Create direct-native examples that keep events package-local while preserving canonical interaction family meaning.
      [x] 4.4.1.2 Subtask - Create canonical-rendered examples that emit and consume boundary events through canonical translation.
      [x] 4.4.1.3 Subtask - Create mixed examples that compare native and canonical event paths for the same workflow.

  [x] 4.5 Section - Phase 4 Integration Tests
    Validate event translation, server authority, and canonical transport behavior end to end.

    [x] 4.5.1 Task - Native and canonical event translation scenarios
      Verify event translation remains canonical where boundaries are crossed and ergonomic where interactions stay local.

      [x] 4.5.1.1 Subtask - Verify direct-native interactions can remain local without compromising later canonical translation.
      [x] 4.5.1.2 Subtask - Verify canonical boundary events use `Jido.Signal` and preserve family and intent meaning.
      [x] 4.5.1.3 Subtask - Verify invalid boundary leakage fails with actionable diagnostics.

    [x] 4.5.2 Task - Server-authoritative runtime event scenarios
      Verify browser hooks and channel participation stay subordinate to the runtime authority.

      [x] 4.5.2.1 Subtask - Verify server-side runtime state remains authoritative across translated events.
      [x] 4.5.2.2 Subtask - Verify hooks only contribute bounded browser capability data rather than runtime decisions.
      [x] 4.5.2.3 Subtask - Verify canonical event handling is consistent across direct-native and canonical-rendered screens.
