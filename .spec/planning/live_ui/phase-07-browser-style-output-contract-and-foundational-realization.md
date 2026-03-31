# Phase 7 - Browser Style Output Contract and Foundational Realization

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `LiveUi.Style`
- `LiveUi.Theme`
- `LiveUi.Renderer`
- `LiveUi.Component`
- `LiveUi.Widgets.Box`
- `LiveUi.Widgets.Button`
- `LiveUi.Widgets.Text`
- `LiveUi.Widgets.TextInput`
- `UnifiedIUR.Style`
- `UnifiedIUR.Theme`
- `UnifiedIUR.Element`

## Relevant Assumptions / Defaults
- `live_ui` already preserves canonical style semantics, but many canonical values still stop at semantic hooks such as `tone`, `variant`, `state`, `class`, and `data-*` markers instead of affecting browser pixels directly.
- The next implementation pass should make canonical style values visibly affect browser rendering without abandoning the existing native theme surface or introducing renderer-local meaning into the canonical boundary.
- Browser realization should be deterministic and shared across direct-native and canonical-rendered paths, so equivalent authored meaning yields equivalent browser-visible output.
- Foundational widgets should set the pattern for later layout, layered, and advanced widget coverage.

[ ] 7 Phase 7 - Browser Style Output Contract and Foundational Realization
  Define the browser-facing style output contract for `live_ui`, implement foundational lowering from canonical style meaning into actual browser-visible rendering, and establish the shared stylesheet/runtime surfaces that later phases can extend.

  [ ] 7.1 Section - Browser Style Output Contract
    Define exactly which canonical style values become browser-visible output and how those values coexist with the current native theme hooks.

    [ ] 7.1.1 Task - Define the realized browser-style surface
      Establish one explicit output contract for how `live_ui` turns canonical style meaning into browser-consumable CSS variables, HTML attrs, classes, or inline values.

      [ ] 7.1.1.1 Subtask - Define which `UnifiedIUR.Style` fields must be realized directly in the browser first, including foreground, background, border color, text attributes, spacing, sizing, alignment, and visibility.
      [ ] 7.1.1.2 Subtask - Define the precedence order between canonical theme resolution, native component defaults, variant and state hooks, local style overrides, and browser-host attrs.
      [ ] 7.1.1.3 Subtask - Define which values remain semantic hooks only versus which ones must become browser-visible CSS output.

    [ ] 7.1.2 Task - Extend native style profiles with realized output data
      Make `LiveUi.Style` carry both the existing semantic hooks and a normalized browser-realization payload.

      [ ] 7.1.2.1 Subtask - Add a browser-style payload to the resolved native style profile that can be consumed uniformly by direct-native and canonical-rendered widgets.
      [ ] 7.1.2.2 Subtask - Ensure `LiveUi.Style.to_assigns/1` and related helpers can emit realized output attrs without discarding the existing `tone`, `variant`, `state`, and `class` hooks.
      [ ] 7.1.2.3 Subtask - Add focused tests that prove the resolved profile is deterministic for equivalent canonical style input.

  [ ] 7.2 Section - Shared Runtime Stylesheet and Foundational Widget Realization
    Replace the current demo-only dependence on bespoke styling with a shared `live_ui` browser stylesheet and first-class foundational widget realization.

    [ ] 7.2.1 Task - Implement shared browser stylesheet delivery
      Create one package-owned stylesheet surface that host apps and demos can load without duplicating widget CSS by hand.

      [ ] 7.2.1.1 Subtask - Introduce a package-facing runtime stylesheet or export surface for `live_ui` browser rendering instead of relying only on inline demo CSS.
      [ ] 7.2.1.2 Subtask - Define how Phoenix hosts, preview tooling, and browser demos consume the shared stylesheet consistently.
      [ ] 7.2.1.3 Subtask - Verify the shared stylesheet can support both theme-driven widget defaults and per-element realized overrides.

    [ ] 7.2.2 Task - Realize foundational widget style values end to end
      Make foundational widgets visibly respond to canonical style values in the browser, not just to semantic classes.

      [ ] 7.2.2.1 Subtask - Implement realized browser styling for `text`, `button`, `text_input`, and `box`, including canonical color, border, spacing, and text-attribute support where applicable.
      [ ] 7.2.2.2 Subtask - Ensure the canonical renderer reuses the same realization path that direct-native widget usage follows.
      [ ] 7.2.2.3 Subtask - Add regression coverage that proves raw canonical style values now affect rendered color and surface treatment in the browser.

  [ ] 7.3 Section - Foundational Host Integration and Fallback Rules
    Define how foundational browser realization behaves when values are partially specified, unsupported, or combined with older semantic styling conventions.

    [ ] 7.3.1 Task - Implement compatibility and fallback behavior
      Keep the renderer usable during the migration from semantic-only styling to direct browser realization.

      [ ] 7.3.1.1 Subtask - Define fallback behavior when canonical style values are absent and only tone, variant, or state semantics are present.
      [ ] 7.3.1.2 Subtask - Ensure legacy demo/example classes such as local `extra.class` hooks continue to work while direct canonical realization is introduced.
      [ ] 7.3.1.3 Subtask - Add diagnostics for foundational style fields that remain unresolved or ignored during browser lowering.

  [ ] 7.4 Section - Phase 7 Integration Tests
    Validate the foundational browser-style contract, shared stylesheet delivery, and first realized widgets end to end.

    [ ] 7.4.1 Task - Foundational style realization integration scenarios
      Verify that the first browser-realized widgets visibly honor canonical style meaning in realistic direct-native and canonical-rendered flows.

      [ ] 7.4.1.1 Subtask - Verify canonical foreground, background, border, and text styling affect the browser output of foundational widgets.
      [ ] 7.4.1.2 Subtask - Verify direct-native and canonical-rendered foundational widgets converge on the same rendered browser-visible result.
      [ ] 7.4.1.3 Subtask - Verify the shared stylesheet is sufficient for host apps, preview tooling, and the maintained demo surface.

    [ ] 7.4.2 Task - Foundational compatibility and fallback integration scenarios
      Verify the migration path remains stable while semantic hooks and direct realized styles coexist.

      [ ] 7.4.2.1 Subtask - Verify tone, variant, and state hooks still style widgets correctly when explicit canonical browser values are absent.
      [ ] 7.4.2.2 Subtask - Verify legacy local classes and attrs remain usable alongside realized canonical output.
      [ ] 7.4.2.3 Subtask - Verify foundational diagnostics catch ignored style input before it silently regresses browser behavior.
