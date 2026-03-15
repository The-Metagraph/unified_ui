# Phase 5 - Canonical IUR Compilation, Introspection, and Parity Validation

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `UnifiedUi.Compiler`
- `UnifiedUi.Info`
- `UnifiedUi.Reference`
- `UnifiedUi.Parity`
- `UnifiedIUR`
- `UnifiedIUR.Extension`

## Relevant Assumptions / Defaults
- `unified_ui` compiles to canonical `UnifiedIUR` only and does not define runtime-specific compile targets.
- Compilation must remain deterministic so authored changes are reviewable and diff-friendly.
- Bilateral parity with `UnifiedIUR` is a package responsibility and should be enforced by the compiler and validation workflow.

[ ] 5 Phase 5 - Canonical IUR Compilation, Introspection, and Parity Validation
  Implement the compiler pipeline that lowers authored DSL modules into canonical `UnifiedIUR`, together with introspection helpers and bilateral parity checks.

  [ ] 5.1 Section - Compiler Pipeline Backbone
    Implement the compiler entrypoints and internal pipeline needed to translate authored `UnifiedUi` modules into canonical output.

    [ ] 5.1.1 Task - Implement authored module compilation entrypoints
      Provide the public compiler surfaces for authored modules and authored fragments.

      [ ] 5.1.1.1 Subtask - Implement public compiler entrypoints for compiling authored UI modules into canonical results.
      [ ] 5.1.1.2 Subtask - Implement internal authored-module extraction and normalization before `UnifiedIUR` emission.
      [ ] 5.1.1.3 Subtask - Define compiler result shapes that include canonical IUR output, compiled signal descriptors, and authored metadata traces.

    [ ] 5.1.2 Task - Implement canonical `UnifiedIUR` emission
      Lower authored widgets, layouts, layers, styles, and signals into the canonical data model.

      [ ] 5.1.2.1 Subtask - Implement lowering from authored foundational and advanced constructs into the corresponding `UnifiedIUR` families.
      [ ] 5.1.2.2 Subtask - Implement lowering from authored display systems and themes into canonical `UnifiedIUR` display and theming constructs.
      [ ] 5.1.2.3 Subtask - Implement lowering from authored interaction and binding declarations into canonical `UnifiedIUR` descriptors.

  [ ] 5.2 Section - Deterministic Resolution Passes
    Implement the compiler passes that resolve authored defaults and remove ambiguity before canonical output is returned.

    [ ] 5.2.1 Task - Implement structural and style-resolution passes
      Resolve authored defaults, inherited semantics, and structural ambiguity into deterministic canonical output.

      [ ] 5.2.1.1 Subtask - Implement default resolution for omitted authored attributes, child slots, and baseline display-system metadata.
      [ ] 5.2.1.2 Subtask - Implement style and theme lowering that resolves theme references, variants, state styles, and local overrides into canonical output.
      [ ] 5.2.1.3 Subtask - Implement layer ordering and structural resolution so authored overlay and viewport semantics compile deterministically.

    [ ] 5.2.2 Task - Implement runtime-independent binding and signal lowering
      Ensure compiled dynamic behavior remains canonical and runtime-independent.

      [ ] 5.2.2.1 Subtask - Implement lowering of authored bindings into canonical path, scope, and default-value descriptors.
      [ ] 5.2.2.2 Subtask - Implement lowering of authored interactions into canonical signal descriptor shapes aligned with `UnifiedIUR`.
      [ ] 5.2.2.3 Subtask - Eliminate renderer-local event names, payload keys, and callback assumptions from compiled output.

  [ ] 5.3 Section - Introspection and Compile Output Inspection
    Implement library-level inspection helpers that let maintainers understand authored and compiled output without a renderer runtime.

    [ ] 5.3.1 Task - Implement compiled artifact summaries and listings
      Provide package surfaces that describe compiled modules and the canonical constructs they contain.

      [ ] 5.3.1.1 Subtask - Implement compiled module summaries for authored identifiers, canonical widget families, and display-system usage.
      [ ] 5.3.1.2 Subtask - Implement compiled listings for signal families, binding paths, themes, and style references used by one authored module.
      [ ] 5.3.1.3 Subtask - Implement package reference helpers that report the currently supported compiled construct families.

    [ ] 5.3.2 Task - Implement review-friendly compile inspection helpers
      Provide readable inspection surfaces for maintainers reviewing canonical output changes.

      [ ] 5.3.2.1 Subtask - Implement helpers that render compiled `UnifiedIUR` summaries without involving runtime libraries.
      [ ] 5.3.2.2 Subtask - Implement helpers that surface compiled signal descriptor summaries and authored-to-canonical traces.
      [ ] 5.3.2.3 Subtask - Implement deterministic inspection output suitable for review and diff-based package maintenance.

  [ ] 5.4 Section - Bilateral Parity and Validation Workflows
    Implement the package validation layer that keeps the authored surface synchronized with `UnifiedIUR`.

    [ ] 5.4.1 Task - Implement bilateral parity catalogs and synchronization checks
      Define the parity expectations between authored `UnifiedUi` surface area and canonical `UnifiedIUR` families.

      [ ] 5.4.1.1 Subtask - Implement package catalogs that report authored widget, display-system, theming, and interaction families.
      [ ] 5.4.1.2 Subtask - Implement synchronization checks against `UnifiedIUR` canonical family catalogs and extension metadata.
      [ ] 5.4.1.3 Subtask - Define parity diagnostics for authored constructs that have no canonical `UnifiedIUR` representation or vice versa.

    [ ] 5.4.2 Task - Implement authored-surface validation workflows
      Enforce authored-surface correctness beyond single-module compile-time validation.

      [ ] 5.4.2.1 Subtask - Implement package validation workflows that compile maintained examples and check deterministic output.
      [ ] 5.4.2.2 Subtask - Implement validation that rejects canonical gaps, unsupported authored declarations, and renderer-specific leakage.
      [ ] 5.4.2.3 Subtask - Implement validation that reports parity-impacting changes in a maintainable, review-friendly form.

  [ ] 5.5 Section - Phase 5 Integration Tests
    Validate compilation, deterministic resolution, inspection, and parity enforcement end to end.

    [ ] 5.5.1 Task - Deterministic compilation and inspection integration scenarios
      Verify authored modules compile into stable canonical `UnifiedIUR` output and usable inspection surfaces.

      [ ] 5.5.1.1 Subtask - Verify equivalent authored input produces identical canonical `UnifiedIUR` output and signal descriptor summaries.
      [ ] 5.5.1.2 Subtask - Verify compiled output inspection surfaces remain readable and deterministic for complex authored modules.
      [ ] 5.5.1.3 Subtask - Verify compiled results preserve authored traceability without runtime-library dependencies.

    [ ] 5.5.2 Task - Parity and validation integration scenarios
      Verify package-level parity checks catch unsafe authored-surface changes.

      [ ] 5.5.2.1 Subtask - Verify parity validation catches authored constructs that are missing from canonical `UnifiedIUR`.
      [ ] 5.5.2.2 Subtask - Verify renderer-specific authoring leakage is rejected by package validation workflows.
      [ ] 5.5.2.3 Subtask - Verify parity and deterministic-compilation failures produce actionable diagnostics for maintainers.
