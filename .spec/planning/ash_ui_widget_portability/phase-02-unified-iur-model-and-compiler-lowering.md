# Phase 2 - UnifiedIUR Model and Compiler Lowering

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `UnifiedUi.Compiler`
- `UnifiedUi.Compiler.Pipeline`
- `UnifiedIUR`
- `UnifiedIUR.Widget`
- `UnifiedIUR.Constructs`
- `UnifiedIUR.Interactions`
- package inspection and export surfaces

## Relevant Assumptions / Defaults
- `unified_iur` preserves canonical widget meaning, repeated collection
  structure, and row-scope binding meaning without renderer-native structs.
- Compiler lowering must not turn promoted widgets into opaque AshUi,
  Phoenix, or runtime escape hatches.
- Runtime packages will consume the same canonical fixtures created in this
  phase.

[ ] 2 Phase 2 - UnifiedIUR Model and Compiler Lowering
  Implement the renderer-independent canonical representation and lowering
  path that carries promoted widget and repeated collection meaning from
  authored `UnifiedUi` modules into `UnifiedIUR`.

  [ ] 2.1 Section - UnifiedIUR Widget Representation
    Add canonical IUR representations for the promoted widget families and
    host-owned form shell concept.

    [ ] 2.1.1 Task - Implement semantic micro-widget canonical nodes
      Represent compact semantic widgets in canonical data structures that
      runtimes can consume consistently.

      [ ] 2.1.1.1 Subtask - Add canonical widget variants or node types for disclosure, kicker, avatar, presence dot, segmented button group, multi-column list item, artifact row, sticky header, and host-owned form shell.
      [ ] 2.1.1.2 Subtask - Preserve content, slot, state, accessibility, style-token, and interaction-binding fields needed by renderers.
      [ ] 2.1.1.3 Subtask - Add normalization rules that keep canonical values deterministic and free of runtime-native structs.

    [ ] 2.1.2 Task - Implement workflow, document, and composer canonical nodes
      Represent richer workflow and document widgets in renderer-independent
      canonical data structures.

      [ ] 2.1.2.1 Subtask - Add canonical widget variants or node types for pipeline stepper, segmented progress, workflow stage list, thin meter, slide-over panel, event callout, inline redline, syntax-highlighted code block, and chat composer.
      [ ] 2.1.2.2 Subtask - Preserve progress, stage, document-diff, code-language, composer-action, panel-placement, and callout-severity semantics without visual-only coupling.
      [ ] 2.1.2.3 Subtask - Add canonical validation for required fields, stable ordering, valid state combinations, and unsupported opaque payloads.

  [ ] 2.2 Section - Repeated Collection and Row-Scope Representation
    Add canonical constructs for repeated collection composition and row-scope
    value references.

    [ ] 2.2.1 Task - Implement repeated collection canonical constructs
      Represent list-driven child-template repetition without Ash relationship
      semantics.

      [ ] 2.2.1.1 Subtask - Add a canonical construct for collection source, item alias, index alias, key expression, empty-state child, and repeated child template.
      [ ] 2.2.1.2 Subtask - Define normalization for nested widgets, layout children, style references, and interaction bindings inside repeated templates.
      [ ] 2.2.1.3 Subtask - Add canonical validation for invalid collection sources, missing child templates, duplicate keys where detectable, and unsupported resource relationship references.

    [ ] 2.2.2 Task - Implement row-scope binding representation
      Preserve row-local value access through canonical binding descriptors
      rather than renderer callback code.

      [ ] 2.2.2.1 Subtask - Add row-scope binding descriptors for child content, style variants, visibility, interaction payloads, and selection state.
      [ ] 2.2.2.2 Subtask - Define how row-scope bindings compose with existing data binding and interaction payload mapping descriptors.
      [ ] 2.2.2.3 Subtask - Add diagnostics for bindings that escape row scope, reference unavailable aliases, or require renderer-local evaluation.

  [ ] 2.3 Section - Compiler Lowering, Fixtures, and Review Output
    Lower authored declarations into canonical IUR and make the results
    testable through fixtures and tooling.

    [ ] 2.3.1 Task - Lower promoted widgets and form shells from UnifiedUi to UnifiedIUR
      Extend the compiler pipeline so the new authored widgets produce stable
      canonical output.

      [ ] 2.3.1.1 Subtask - Lower each promoted widget declaration into the matching canonical IUR node with content, style, state, and interaction meaning preserved.
      [ ] 2.3.1.2 Subtask - Lower host-owned form shell declarations without introducing Phoenix form structs, Ash changesets, or runtime-specific lifecycle values.
      [ ] 2.3.1.3 Subtask - Add compiler diagnostics when authored declarations cannot be represented in canonical IUR.

    [ ] 2.3.2 Task - Lower repeated collection templates into canonical constructs
      Extend the compiler pipeline so repeated templates become stable IUR
      constructs with preserved row-scope semantics.

      [ ] 2.3.2.1 Subtask - Lower collection source, aliases, key expression, empty state, and child template into canonical repeated collection data.
      [ ] 2.3.2.2 Subtask - Lower row-scope content, style, and interaction payload references into canonical binding descriptors.
      [ ] 2.3.2.3 Subtask - Add canonical fixtures that cover promoted widgets inside and outside repeated collection templates.

    [ ] 2.3.3 Task - Extend canonical inspection, export, and validation tooling
      Make the new IUR surface visible, deterministic, and suitable for runtime
      conformance fixtures.

      [ ] 2.3.3.1 Subtask - Update `unified_iur` inspection output to print promoted widget type, required semantic fields, degradation hints, and child template structure.
      [ ] 2.3.3.2 Subtask - Update export and validation workflows to reject opaque integration-package escape hatches.
      [ ] 2.3.3.3 Subtask - Add shared fixture files or fixture modules that every runtime can reuse to validate rendering parity.

  [ ] 2.4 Section - Phase 2 Integration Tests
    Validate compiler lowering, canonical representation, row-scope bindings,
    and canonical tooling end to end.

    [ ] 2.4.1 Task - Compiler and IUR representation scenarios
      Verify authored promoted widgets compile into stable canonical IUR
      without losing semantic meaning.

      [ ] 2.4.1.1 Subtask - Verify every promoted widget lowers into a canonical node with expected content, state, style, and interaction fields.
      [ ] 2.4.1.2 Subtask - Verify host-owned form shell lowering contains portable lifecycle metadata but no Phoenix, AshPhoenix, or Ash resource values.
      [ ] 2.4.1.3 Subtask - Verify canonical output remains deterministic across equivalent authored declarations.

    [ ] 2.4.2 Task - Repeated collection and tooling scenarios
      Verify repeated collection meaning and row-scope bindings survive
      canonical lowering and review output.

      [ ] 2.4.2.1 Subtask - Verify repeated collection fixtures preserve collection source, row aliases, keys, empty states, child templates, and row-scope payload mappings.
      [ ] 2.4.2.2 Subtask - Verify invalid row-scope references and integration-package escape hatches fail validation.
      [ ] 2.4.2.3 Subtask - Verify inspect, export, and validate workflows produce stable review output for promoted widgets and repeated templates.
