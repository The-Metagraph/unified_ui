# Phase 4 - Compiler, IUR, Tooling, and Runtime Alignment

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `UnifiedUi.Compiler`
- `UnifiedUi.Tooling`
- `UnifiedIUR.Element`
- `UnifiedIUR.Style`
- `UnifiedIUR.Theme`
- `UnifiedIUR.Inspect`
- `LiveUi.Style`
- Runtime IUR renderers

## Relevant Assumptions / Defaults

- `UnifiedIUR` receives canonical style and theme data, not raw authored CSS.
- CSS-derived provenance and diagnostics are renderer-independent tooling data
  and may be omitted from runtime rendering when not needed.
- Runtime packages continue to own native style realization and may use CSS,
  classes, terminal attributes, desktop drawing primitives, or other native
  mechanisms to realize canonical style data.
- Examples should demonstrate CSS authoring and canonical output without
  implying full browser CSS coverage.

[ ] 4 Phase 4 - Compiler, IUR, Tooling, and Runtime Alignment
  Integrate CSS-derived styles into deterministic compiler output, canonical
  IUR representation, author tooling, examples, and runtime realization checks.

  [x] 4.1 Section - Compiler Pass Integration and Deterministic Output
    Place CSS parsing, matching, cascade, and declaration lowering into the
    compiler pipeline without destabilizing existing style and theme behavior.

    [x] 4.1.1 Task - Integrate CSS lowering into the compiler pipeline
      Choose the compiler pass boundaries and data flow for CSS-derived style
      output.

      [x] 4.1.1.1 Subtask - Insert CSS parser, selector matching, cascade, and declaration translation before final canonical IUR style attachment emission.
      [x] 4.1.1.2 Subtask - Ensure CSS-derived style data participates in the documented style precedence model.
      [x] 4.1.1.3 Subtask - Preserve deterministic output for equivalent authored modules, including generated node identities and source-order ties.
      [x] 4.1.1.4 Subtask - Keep renderer-specific CSS output out of the `unified_ui` compiler.

    [x] 4.1.2 Task - Preserve existing style and theme compatibility
      Verify CSS authoring is additive and does not break existing explicit
      style, theme, variant, and class behavior.

      [x] 4.1.2.1 Subtask - Maintain current theme defaults, component variants, style references, local style values, and direct widget prop behavior.
      [x] 4.1.2.2 Subtask - Ensure current authored `class` behavior remains available for runtime hooks and selector metadata.
      [x] 4.1.2.3 Subtask - Add migration guidance that positions CSS blocks as optional authoring input rather than a replacement for canonical style APIs.
      [x] 4.1.2.4 Subtask - Verify existing compiler fixtures and examples remain stable unless they intentionally add CSS blocks.

  [ ] 4.2 Section - UnifiedIUR Representation and Provenance
    Represent CSS-derived results as canonical style and theme data while
    preserving optional provenance for debugging and inspection.

    [ ] 4.2.1 Task - Add or confirm canonical style attachment support
      Ensure IUR elements and theme structures can carry the effective style
      values produced by CSS lowering.

      [ ] 4.2.1.1 Subtask - Confirm existing IUR style and theme structures can represent the supported CSS declaration map.
      [ ] 4.2.1.2 Subtask - Add canonical style fields only when the style concept is portable and needed beyond CSS authoring.
      [ ] 4.2.1.3 Subtask - Avoid adding raw CSS text as a required IUR field or renderer input.
      [ ] 4.2.1.4 Subtask - Preserve renderer-independent diagnostics or provenance metadata only where tooling needs to explain CSS-derived output.

    [ ] 4.2.2 Task - Align IUR normalization and inspection
      Make CSS-derived style data deterministic, inspectable, and safe for
      runtime renderer consumption.

      [ ] 4.2.2.1 Subtask - Normalize CSS-derived style maps with the same ordering and value normalization rules as hand-authored canonical styles.
      [ ] 4.2.2.2 Subtask - Expose provenance that can identify source block, selector, declaration, and cascade reason for selected style values.
      [ ] 4.2.2.3 Subtask - Ensure IUR inspection shows canonical style data as canonical data, not as browser CSS.
      [ ] 4.2.2.4 Subtask - Ensure IUR validation rejects raw CSS interchange fields outside optional tooling metadata.

  [ ] 4.3 Section - Tooling, Examples, Documentation, and Runtime Alignment
    Complete the author-facing and runtime-facing surfaces needed to make CSS
    style authoring understandable and portable.

    [ ] 4.3.1 Task - Update tooling and examples
      Document and demonstrate CSS authoring, canonical lowering, diagnostics,
      and caveats through maintained examples and inspect/export tools.

      [ ] 4.3.1.1 Subtask - Add examples showing CSS class, id, kind, and state selectors lowering into canonical style data.
      [ ] 4.3.1.2 Subtask - Add examples showing unsupported CSS ignored with diagnostics and without raw CSS passthrough.
      [ ] 4.3.1.3 Subtask - Update `mix unified_ui.inspect`, `mix unified_ui.export`, and validation output to surface CSS block summaries and lowering diagnostics.
      [ ] 4.3.1.4 Subtask - Update documentation to state the caveat that accepted CSS syntax does not mean full browser CSS semantic equivalence.

    [ ] 4.3.2 Task - Verify runtime renderer realization boundaries
      Check that runtimes consume the resulting canonical style data through
      their existing native rendering boundaries.

      [ ] 4.3.2.1 Subtask - Verify `live_ui` realizes CSS-derived canonical style values through its native style and class mechanisms without requiring authored CSS blocks at render time.
      [ ] 4.3.2.2 Subtask - Define parity checks for `elm_ui`, `desktop_ui`, and `terminal_ui` based on canonical style values rather than raw CSS.
      [ ] 4.3.2.3 Subtask - Document terminal and desktop degradation expectations for style concepts that cannot be visually identical to browser CSS.
      [ ] 4.3.2.4 Subtask - Ensure runtime-specific stylesheet loading remains a runtime concern and is not required by canonical CSS block lowering.

  [ ] 4.4 Section - Phase 4 Integration Tests
    Validate end-to-end CSS authoring from DSL input through canonical IUR and
    runtime-facing realization checks.

    [ ] 4.4.1 Task - End-to-end compiler and IUR scenarios
      Verify CSS stylesheet blocks produce deterministic canonical output and
      diagnostics through the full compiler path.

      [ ] 4.4.1.1 Subtask - Verify a CSS-authored module compiles into canonical IUR style attachments with no raw CSS runtime field.
      [ ] 4.4.1.2 Subtask - Verify CSS-derived style values merge correctly with theme defaults, style references, local styles, variants, and direct props.
      [ ] 4.4.1.3 Subtask - Verify inspection explains source block, selector, declaration, cascade reason, and ignored constructs for representative CSS-derived values.
      [ ] 4.4.1.4 Subtask - Verify canonical IUR validation accepts CSS-derived canonical style data and rejects required raw CSS interchange data.

    [ ] 4.4.2 Task - Tooling and runtime boundary scenarios
      Verify author tooling and runtime renderers observe the canonical
      boundary established by the ADR and specs.

      [ ] 4.4.2.1 Subtask - Verify inspect/export/validate commands report CSS authoring summaries and diagnostics deterministically.
      [ ] 4.4.2.2 Subtask - Verify maintained examples demonstrate supported selectors, supported declarations, ignored unsupported CSS, and the semantic-equivalence caveat.
      [ ] 4.4.2.3 Subtask - Verify `live_ui` renders representative CSS-derived canonical style output through native style realization without needing the authored CSS block.
      [ ] 4.4.2.4 Subtask - Verify cross-runtime parity checks compare canonical style meaning and documented degradation rather than raw CSS output.
