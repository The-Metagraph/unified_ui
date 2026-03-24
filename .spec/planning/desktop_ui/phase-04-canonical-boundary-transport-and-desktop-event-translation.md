# Phase 4 - Canonical Boundary Transport and Desktop Event Translation

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `DesktopUi.Transport`
- `DesktopUi.Transport.Signal`
- `DesktopUi.Transport.Normalize`
- `DesktopUi.Runtime.EventRouter`
- `Jido.Signal`

## Relevant Assumptions / Defaults
- Direct native `desktop_ui` usage may keep interactions local until they cross
  a package boundary.
- Canonical boundary meaning should be translated once through bounded transport
  modules rather than leaking SDL2 or platform-local envelopes.
- The shared runtime remains the source of normalized desktop interaction
  meaning even when individual targets expose different raw callbacks.

[x] 4 Phase 4 - Canonical Boundary Transport and Desktop Event Translation
  Implement canonical `Jido.Signal` boundary translation, normalized desktop
  event flow, and transport diagnostics for direct-native and canonical
  rendering paths.

  [x] 4.1 Section - Canonical Event Translation Backbone
    Implement the canonical boundary translation model that turns normalized
    desktop interactions into cross-package signals and back again.

    [x] 4.1.1 Task - Implement canonical boundary signal translation
      Define the translation layer for canonical event descriptors,
      `Jido.Signal`, and CloudEvents-compatible transport semantics.

      [x] 4.1.1.1 Subtask - Implement transport modules that map canonical interaction descriptors to boundary signal definitions and back again.
      [x] 4.1.1.2 Subtask - Define the canonical event envelope shape used whenever interactions cross the package boundary.
      [x] 4.1.1.3 Subtask - Keep canonical boundary translation aligned with authored `unified_ui` signal descriptors and canonical `UnifiedIUR` interaction payloads.

    [x] 4.1.2 Task - Implement native desktop input normalization
      Normalize SDL2 and platform-local input into one shared native desktop
      interaction model before boundary translation occurs.

      [x] 4.1.2.1 Subtask - Define the shared native desktop event model for clicks, key input, focus changes, shortcuts, menus, and window-local events.
      [x] 4.1.2.2 Subtask - Normalize SDL2 and platform-local input families into the shared native event model before any canonical translation occurs.
      [x] 4.1.2.3 Subtask - Add diagnostics for unsupported raw input payloads, invalid normalization state, and ambiguous native event interpretation.

  [x] 4.2 Section - Shared Runtime Event Flow
    Implement the shared runtime event flow that connects normalized native
    events, local runtime handling, and canonical boundary translation.

    [x] 4.2.1 Task - Implement boundary-crossing event routing
      Route normalized desktop interactions through canonical transport modules
      whenever the interaction leaves the package boundary.

      [x] 4.2.1.1 Subtask - Implement runtime routing from widget interactions and canonical binding attachments into boundary translation modules.
      [x] 4.2.1.2 Subtask - Implement inbound handling for canonical boundary signals that need to update native runtime state or widget realization.
      [x] 4.2.1.3 Subtask - Keep event routing shared between direct-native and canonical-rendered screens.

    [x] 4.2.2 Task - Implement local native interaction handling without boundary leakage
      Preserve the ability to handle local native runtime behavior directly
      while keeping renderer-local details out of the cross-package contract.

      [x] 4.2.2.1 Subtask - Implement package-local handling for local shortcuts, focus shifts, menu navigation, and window-management behavior that stays inside the runtime.
      [x] 4.2.2.2 Subtask - Distinguish local native event handling from boundary-crossing signals without changing interaction family meaning.
      [x] 4.2.2.3 Subtask - Add diagnostics for leaked renderer-local event names, raw platform payloads, and invalid boundary/local routing decisions.

  [x] 4.3 Section - Transport Diagnostics and Contract Hygiene
    Implement inspection and validation surfaces that keep the desktop transport
    layer deterministic and free of boundary leakage.

    [x] 4.3.1 Task - Implement transport diagnostics and validation helpers
      Provide package-local tooling that inspects boundary signal mappings,
      normalization rules, and no-leakage guarantees.

      [x] 4.3.1.1 Subtask - Implement inspection helpers that list canonical-to-native interaction mappings and normalized event families.
      [x] 4.3.1.2 Subtask - Implement validation helpers that catch raw SDL2 or platform-local leakage at the package boundary.
      [x] 4.3.1.3 Subtask - Report deterministic diagnostics for unsupported canonical events, ambiguous routing, and invalid signal payloads.

    [x] 4.3.2 Task - Implement transport-focused reference summaries
      Keep transport boundaries visible to maintainers as the runtime grows more
      complex.

      [x] 4.3.2.1 Subtask - Expose transport summaries through package reference helpers and tooling surfaces.
      [x] 4.3.2.2 Subtask - Highlight where local native event families remain local and where canonical translation is required.
      [x] 4.3.2.3 Subtask - Keep transport summaries aligned with later validation and release-readiness workflows.

  [x] 4.4 Section - Transport Comparison Examples
    Implement maintained examples that compare native-local handling and
    boundary-crossing event translation across the desktop runtime.

    [x] 4.4.1 Task - Implement transport-oriented native and canonical examples
      Provide maintained examples that exercise canonical signals, local native
      input, and normalized desktop interaction families.

      [x] 4.4.1.1 Subtask - Add direct-native examples that exercise focus, shortcuts, menus, and window-management interactions.
      [x] 4.4.1.2 Subtask - Add canonical-rendered examples that exercise the same interaction families through `Jido.Signal` translation.
      [x] 4.4.1.3 Subtask - Keep transport example metadata aligned with package reference and validation surfaces.

    [x] 4.4.2 Task - Implement normalized-input comparison helpers
      Help maintainers compare how the same interaction family is normalized
      across supported desktop targets.

      [x] 4.4.2.1 Subtask - Add helper workflows that compare normalized input across Windows, macOS, and Linux adapters.
      [x] 4.4.2.2 Subtask - Show how local native handling differs from canonical boundary translation without changing event meaning.
      [x] 4.4.2.3 Subtask - Document where later release workflows will package and validate these interaction families.

  [x] 4.5 Section - Phase 4 Integration Tests
    Validate canonical transport, normalized input flow, and contract hygiene
    end to end.

    [x] 4.5.1 Task - Boundary translation integration scenarios
      Verify canonical desktop interactions cross the package boundary through
      deterministic `Jido.Signal` translation.

      [x] 4.5.1.1 Subtask - Verify boundary-crossing interactions emit and consume canonical signals with CloudEvents-compatible semantics.
      [x] 4.5.1.2 Subtask - Verify canonical bindings and event descriptors route correctly through native widget interactions.
      [x] 4.5.1.3 Subtask - Verify invalid canonical event payloads or leaked platform-local envelopes fail with deterministic diagnostics.

    [x] 4.5.2 Task - Local-native and normalized-input integration scenarios
      Verify local native event handling and platform normalization stay bounded
      inside the shared runtime while preserving canonical meaning when needed.

      [x] 4.5.2.1 Subtask - Verify local native interactions can remain inside the runtime without forcing unnecessary boundary translation.
      [x] 4.5.2.2 Subtask - Verify normalized input families remain consistent across platform adapters and direct-native versus canonical entry paths.
      [x] 4.5.2.3 Subtask - Verify transport diagnostics surface boundary-local distinctions and no-leakage guarantees clearly.
