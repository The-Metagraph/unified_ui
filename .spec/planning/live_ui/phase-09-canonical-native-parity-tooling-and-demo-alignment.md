# Phase 9 - Canonical-Native Parity, Tooling, and Demo Alignment

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `LiveUi.Style`
- `LiveUi.Renderer`
- `LiveUi.Tooling`
- `LiveUi.Info`
- `LiveUi.Reference`
- `LiveUi.Demo`
- `LiveUi.Runtime.ScreenComponent`
- `UnifiedIUR.Inspect`
- `UnifiedIUR.Reference`

## Relevant Assumptions / Defaults
- Once browser-realized canonical style output exists, maintainers will need better visibility into what canonical style values were resolved, emitted, ignored, or approximated.
- The maintained `live_ui` demo and package examples should become the clearest proof that raw canonical style values now affect browser-visible output.
- Continuity checks should fail when direct-native and canonical-rendered style realization drift in user-visible ways, not only when widget-family coverage drifts.
- Maintainer tooling should distinguish true browser-realized style support from semantic-only compatibility or fallback behavior.

[ ] 9 Phase 9 - Canonical-Native Parity, Tooling, and Demo Alignment
  Make browser-realized style parity observable and enforceable, upgrade the maintained demo/examples to exercise the new capabilities directly, and give maintainers the diagnostics needed to understand realized versus unresolved style behavior.

  [ ] 9.1 Section - Canonical-Native Browser Parity Rules
    Expand continuity rules so browser-visible style output becomes a first-class parity concern across direct-native and canonical-rendered paths.

    [ ] 9.1.1 Task - Define browser-visible parity expectations
      Establish what counts as aligned browser-visible style output between native and canonical render paths.

      [ ] 9.1.1.1 Subtask - Define parity expectations for color, emphasis, spacing, layout treatment, and state-aware browser styling across paired native and canonical examples.
      [ ] 9.1.1.2 Subtask - Define acceptable approximation rules for values that cannot be realized identically but can still preserve canonical meaning.
      [ ] 9.1.1.3 Subtask - Add regression criteria that fail when canonical browser realization drifts from direct-native rendering in maintained examples.

    [ ] 9.1.2 Task - Implement parity diagnostics and drift reporting
      Make browser-style drift inspectable in tooling rather than discoverable only by visual review.

      [ ] 9.1.2.1 Subtask - Extend comparison tooling to report resolved canonical browser-style payloads for native and canonical example pairs.
      [ ] 9.1.2.2 Subtask - Add diagnostics that identify whether a visible difference came from theme defaults, local classes, unresolved canonical fields, or host stylesheet gaps.
      [ ] 9.1.2.3 Subtask - Add tests that prove parity tooling catches browser-visible drift and ignored style fields reliably.

  [ ] 9.2 Section - Inspection, Preview, and Maintainer Tooling Enhancements
    Extend package tooling so maintainers can inspect the actual browser-realized style surface instead of only semantic hooks.

    [ ] 9.2.1 Task - Implement realized-style inspection surfaces
      Make the resolved browser-style payload part of preview, inspect, and reference workflows.

      [ ] 9.2.1.1 Subtask - Extend inspection output to show resolved canonical style, emitted browser attrs or CSS variables, and fallback status per element.
      [ ] 9.2.1.2 Subtask - Extend preview/export workflows so maintainers can capture browser-realized style data together with rendered HTML.
      [ ] 9.2.1.3 Subtask - Add tests that prove tooling output remains readable while exposing richer style-realization data.

    [ ] 9.2.2 Task - Implement unsupported-style and fallback reporting
      Surface the style fields that are still semantic-only, approximated, or dropped.

      [ ] 9.2.2.1 Subtask - Add package-facing diagnostics for unhandled canonical style fields and unresolved token or role references.
      [ ] 9.2.2.2 Subtask - Add maintainer-oriented summaries that separate browser-realized support from semantic-only compatibility.
      [ ] 9.2.2.3 Subtask - Add tests that prove unsupported-style reporting fails clearly when newly authored canonical style values would be ignored.

  [ ] 9.3 Section - Demo and Maintained Example Alignment
    Upgrade the maintained demo and example catalog so they showcase direct canonical browser-style realization instead of relying mostly on bespoke local classes.

    [ ] 9.3.1 Task - Retrofit the maintained demo to prove canonical style realization
      Make the browser-hosted `live_ui` demo a first-class proof that canonical style values produce visible browser output.

      [ ] 9.3.1.1 Subtask - Update the demo workbench so its own browser-facing chrome uses the shared `live_ui` stylesheet and browser-realized canonical styles.
      [ ] 9.3.1.2 Subtask - Add dedicated demo scenarios that highlight canonical color, spacing, and state-variant realization in the browser.
      [ ] 9.3.1.3 Subtask - Add regression coverage that proves the demo no longer depends primarily on bespoke demo-only CSS classes to show style differences.

    [ ] 9.3.2 Task - Retrofit maintained style examples for canonical-first proof
      Rework the package examples so canonical browser realization is obvious and reviewable.

      [ ] 9.3.2.1 Subtask - Update paired styled examples to rely more on canonical style values and less on hand-authored `extra.class` styling.
      [ ] 9.3.2.2 Subtask - Add paired comparison scenarios that prove direct-native and canonical-rendered paths remain visually aligned under the new browser realization model.
      [ ] 9.3.2.3 Subtask - Add tests that prove styled example regressions are caught when visible browser output stops matching canonical style intent.

  [ ] 9.4 Section - Phase 9 Integration Tests
    Validate parity tooling, style diagnostics, and maintained demo/example alignment end to end.

    [ ] 9.4.1 Task - Browser-style parity and tooling integration scenarios
      Verify maintainers can inspect and compare realized browser styling across representative native and canonical example pairs.

      [ ] 9.4.1.1 Subtask - Verify comparison tooling reports browser-visible style parity or drift for representative foundational and advanced example pairs.
      [ ] 9.4.1.2 Subtask - Verify inspection and preview surfaces expose resolved browser-style payloads clearly.
      [ ] 9.4.1.3 Subtask - Verify unsupported-style reporting remains actionable and does not collapse into raw unreadable debug output.

    [ ] 9.4.2 Task - Demo and example alignment integration scenarios
      Verify the maintained browser demo and example catalog visibly prove the new browser-realized canonical style behavior.

      [ ] 9.4.2.1 Subtask - Verify the demo shell and runtime surfaces remain styled through `live_ui` rather than bespoke host-only markup assumptions.
      [ ] 9.4.2.2 Subtask - Verify paired styled examples still converge on the same browser-visible meaning across native and canonical paths.
      [ ] 9.4.2.3 Subtask - Verify reviewer-facing workflows can now identify raw canonical style changes by looking at browser output instead of only semantic metadata.
