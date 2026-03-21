# Phase 5 - Native Styling, Runtime Inspection, and Native-IUR Continuity

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `WebUi.Style`
- `WebUi.Theme`
- `WebUi.Info`
- `WebUi.Reference`
- `WebUi.Renderer`
- `WebUi.Server`
- `WebUi.Frontend`
- `UnifiedIUR.Theme`

## Relevant Assumptions / Defaults
- Styling and theming should remain native `web_ui` capabilities that can still express canonical styling and theming meaning.
- Inspection surfaces should make the Phoenix and Elm split reviewable instead of hiding server state, frontend state, or canonical mapping details.
- Native and canonical continuity should be validated explicitly so the package does not drift into separate direct-native and canonical experiences.

[ ] 5 Phase 5 - Native Styling, Runtime Inspection, and Native-IUR Continuity
  Implement native theming and styling, cross-runtime inspection surfaces, and deterministic continuity between direct native and canonical rendering paths.

  [x] 5.1 Section - Native Styling and Theming Surface
    Implement the style and theme system that native widgets and canonical rendering will share.

    [x] 5.1.1 Task - Implement native style primitives and widget style hooks
      Define the style primitives, widget-level style hooks, and state-variant behavior required across native widget families.

      [x] 5.1.1.1 Subtask - Implement native style primitives for typography, color, spacing, sizing, alignment, borders, background treatment, visibility, and emphasis.
      [x] 5.1.1.2 Subtask - Define how widget families expose variant, tone, state, and composition-aware style hooks across the split runtime.
      [x] 5.1.1.3 Subtask - Keep style primitives portable enough to preserve canonical styling meaning without becoming renderer-local escape hatches.

    [x] 5.1.2 Task - Implement native theme and token support
      Define the native theming surface needed for coherent package styling and canonical theme interpretation.

      [x] 5.1.2.1 Subtask - Implement native theme definitions, palette roles, token references, and component-style defaults.
      [x] 5.1.2.2 Subtask - Define how the server runtime carries authoritative theme meaning while the frontend realizes browser-facing style output.
      [x] 5.1.2.3 Subtask - Define continuity rules for theme inheritance, token resolution, and style fallback behavior.

  [ ] 5.2 Section - Cross-Runtime Style Realization
    Implement the Phoenix-side and Elm-side coordination needed to realize styling and theming coherently.

    [ ] 5.2.1 Task - Implement authoritative style resolution on the server side
      Define how style defaults, theme tokens, and resolved presentation meaning are computed before frontend realization.

      [ ] 5.2.1.1 Subtask - Implement server-side resolution for style defaults, theme tokens, and state-aware widget styling.
      [ ] 5.2.1.2 Subtask - Define deterministic resolved style payloads sent to the frontend runtime for browser realization.
      [ ] 5.2.1.3 Subtask - Add diagnostics for unresolved tokens, incompatible style combinations, and invalid state-variant wiring.

    [ ] 5.2.2 Task - Implement frontend style realization and browser continuity
      Define how the frontend runtime realizes server-provided style meaning while supporting bounded browser responsiveness.

      [ ] 5.2.2.1 Subtask - Implement Elm-side style realization for resolved widget, layout, and layer styling.
      [ ] 5.2.2.2 Subtask - Implement bounded browser-facing transitions, responsive layout behavior, and local visual feedback without redefining canonical style meaning.
      [ ] 5.2.2.3 Subtask - Ensure frontend style realization remains reviewable and deterministic for the same authoritative input state.

  [ ] 5.3 Section - Runtime Inspection and Diagnostics
    Implement inspection surfaces that expose native widget styling, server state, frontend realization, and canonical mapping details.

    [ ] 5.3.1 Task - Implement package inspection summaries
      Provide package helpers that summarize widget catalogs, style capabilities, runtime assumptions, and renderer coverage.

      [ ] 5.3.1.1 Subtask - Implement inspection helpers that summarize widget families, style primitives, theme catalogs, and renderer coverage.
      [ ] 5.3.1.2 Subtask - Implement inspection helpers that expose server-side resolved style state and frontend-facing realization state.
      [ ] 5.3.1.3 Subtask - Keep inspection surfaces usable without requiring maintainers to manually reconstruct the split runtime.

    [ ] 5.3.2 Task - Implement native and canonical continuity diagnostics
      Provide diagnostics that make drift between direct native and canonical rendering paths visible.

      [ ] 5.3.2.1 Subtask - Implement continuity reports that compare native and canonical widget identity, styling, and runtime behavior.
      [ ] 5.3.2.2 Subtask - Implement diagnostics for mismatched style resolution, missing theme propagation, and frontend realization drift.
      [ ] 5.3.2.3 Subtask - Define actionable validation output that points maintainers toward the failing package seam.

  [ ] 5.4 Section - Continuity Examples and Review Artifacts
    Implement maintained examples and review artifacts that demonstrate native and canonical continuity for styling-heavy workflows.

    [ ] 5.4.1 Task - Implement styling-focused comparison examples
      Provide reference examples that make native and canonical styling behavior reviewable across the split runtime.

      [ ] 5.4.1.1 Subtask - Create direct-native styling examples that exercise themes, variants, tones, and layered styling behavior.
      [ ] 5.4.1.2 Subtask - Create canonical-rendered styling examples that exercise equivalent theme and style meaning through `UnifiedIUR`.
      [ ] 5.4.1.3 Subtask - Create comparison artifacts that show resolved style state, frontend realization state, and continuity outcomes side by side.

  [ ] 5.5 Section - Phase 5 Integration Tests
    Validate styling, theming, inspection surfaces, and native-IUR continuity end to end.

    [ ] 5.5.1 Task - Styling and theming integration scenarios
      Verify the style and theme system behaves coherently across the server and frontend runtimes.

      [ ] 5.5.1.1 Subtask - Verify server-side style resolution and frontend realization produce deterministic results for the same widget state.
      [ ] 5.5.1.2 Subtask - Verify themes, tokens, and state variants preserve canonical styling meaning for both native and canonical paths.
      [ ] 5.5.1.3 Subtask - Verify invalid style combinations, unresolved tokens, and theme drift fail with actionable diagnostics.

    [ ] 5.5.2 Task - Continuity and inspection integration scenarios
      Verify maintainers can inspect and compare native versus canonical behavior without hidden runtime seams.

      [ ] 5.5.2.1 Subtask - Verify inspection surfaces expose widget catalogs, resolved style state, and frontend realization state.
      [ ] 5.5.2.2 Subtask - Verify continuity reports detect mismatches between direct native and canonical rendering paths.
      [ ] 5.5.2.3 Subtask - Verify styling-heavy examples remain reviewable through comparison artifacts and package-facing tooling.
