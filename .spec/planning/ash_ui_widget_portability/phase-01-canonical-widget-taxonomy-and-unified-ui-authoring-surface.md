# Phase 1 - Canonical Widget Taxonomy and UnifiedUi Authoring Surface

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `UnifiedUi`
- `UnifiedUi.Dsl`
- `UnifiedUi.Compiler`
- `UnifiedUi.Tooling`
- `packages/unified-ui` widget and composition modules
- `.spec/specs/unified-ui/dsl.spec.md`
- `.spec/specs/unified-ui/widgets.spec.md`

## Relevant Assumptions / Defaults
- The promoted widget set is canonical only when expressed without Ash,
  Phoenix, or renderer-local assumptions.
- Semantic micro widgets, workflow/document widgets, host-owned form shells,
  and repeated collection templates can be introduced incrementally while
  preserving the existing authored module model.
- Repeated collection authoring is list-oriented data binding plus a child
  template, not resource relationship traversal.

[ ] 1 Phase 1 - Canonical Widget Taxonomy and UnifiedUi Authoring Surface
  Establish the canonical authored surface in `unified_ui` so developers can
  declare the promoted widgets and repeated collection templates before
  renderer-specific work begins.

  [x] 1.1 Section - Canonical Widget Taxonomy
    Define the canonical names, widget families, content models, and authoring
    boundaries for the AshUi-originated surface.

    [x] 1.1.1 Task - Define semantic micro-widget authoring contracts
      Establish the authored meaning and allowed fields for compact semantic
      and status-oriented widgets.

      [x] 1.1.1.1 Subtask - Define canonical authoring contracts for `disclosure`, `kicker`, `avatar`, `presence_dot`, `segmented_button_group`, `list_item_multi_column`, `artifact_row`, and `sticky_header`.
      [x] 1.1.1.2 Subtask - Define each widget's content model, state model, style hooks, accessibility labels, and interaction bindings without renderer-specific callback names.
      [x] 1.1.1.3 Subtask - Add authoring validation that rejects AshUi-only option names or runtime-only styling shortcuts at the canonical boundary.

    [x] 1.1.2 Task - Define workflow, document, and composer authoring contracts
      Establish the authored meaning and allowed fields for richer workflow,
      document, and communication widgets.

      [x] 1.1.2.1 Subtask - Define canonical authoring contracts for `pipeline_stepper_horizontal`, `segmented_progress_bar`, `workflow_stage_list_vertical`, `meter_thin`, `slide_over_panel`, `event_callout`, `redline_inline`, `code_block_syntax_highlighted`, and `chat_composer`.
      [x] 1.1.2.2 Subtask - Define data, child-slot, selection, progress, document-diff, syntax metadata, and composer action fields in renderer-independent terms.
      [x] 1.1.2.3 Subtask - Add validation that distinguishes required canonical semantics from optional runtime visual treatments.

    [x] 1.1.3 Task - Define host-owned form shell authoring semantics
      Map the AshUi `phoenix_form` proposal onto a portable host-owned form
      shell concept.

      [x] 1.1.3.1 Subtask - Define the canonical form-shell fields for host lifecycle ownership, submit intent, validation summary, field grouping, and action placement.
      [x] 1.1.3.2 Subtask - Define how form shell authoring composes existing canonical field, form builder, and action widgets without naming Phoenix or AshPhoenix APIs.
      [x] 1.1.3.3 Subtask - Add diagnostics for Phoenix-specific, Ash-specific, or runtime-owned form lifecycle declarations that do not belong in the canonical DSL.

  [x] 1.2 Section - Repeated Collection Authoring
    Implement the authored repeated-collection template surface and row-scope
    binding rules.

    [x] 1.2.1 Task - Define the repeated collection DSL shape
      Establish how authors bind list data to one child widget or layout
      template per item.

      [x] 1.2.1.1 Subtask - Define the authored fields for collection source, item alias, index alias, key expression, empty state, and child template.
      [x] 1.2.1.2 Subtask - Define row-scope value references for child widgets, styles, and interaction payload mappings.
      [x] 1.2.1.3 Subtask - Reject Ash relationship names, resource traversal assumptions, and renderer-local iteration callbacks in canonical repeated collection declarations.

    [x] 1.2.2 Task - Integrate repeated templates with existing composition rules
      Make repeated collection templates fit existing widget, layout, style, and
      interaction authoring rules.

      [x] 1.2.2.1 Subtask - Ensure repeated templates can contain promoted widgets, existing widgets, layouts, bindings, style variants, and theme references.
      [x] 1.2.2.2 Subtask - Define parent-child placement constraints for repeated templates so they cannot create invalid layer or overlay structures.
      [x] 1.2.2.3 Subtask - Add compile-time diagnostics for ambiguous row scope, invalid child placement, missing keys where required, and unsupported nested collection shapes.

  [ ] 1.3 Section - Authoring Introspection and Guidance
    Make the new authoring surface discoverable and reviewable through
    `unified_ui` tooling and package guidance.

    [ ] 1.3.1 Task - Extend authoring inspection and export output
      Show the promoted widgets and repeated collection templates clearly in
      existing review surfaces.

      [ ] 1.3.1.1 Subtask - Extend inspection output to show canonical widget family, required fields, optional slots, state, and interaction binding summaries.
      [ ] 1.3.1.2 Subtask - Extend export output to include repeated collection source, row-scope aliases, child template identity, and key semantics deterministically.
      [ ] 1.3.1.3 Subtask - Add fixtures that prove equivalent authored declarations produce stable inspection and export output.

    [ ] 1.3.2 Task - Add initial authoring examples and migration notes
      Provide author-facing examples that explain how the AshUi-originated
      concepts map into canonical `UnifiedUi`.

      [ ] 1.3.2.1 Subtask - Add examples for one semantic micro-widget flow, one workflow/document flow, one host-owned form shell, and one repeated collection template.
      [ ] 1.3.2.2 Subtask - Document naming differences between AshUi proposals and canonical concepts when the canonical name is intentionally more portable.
      [ ] 1.3.2.3 Subtask - Document which AshUi proposal details remain integration-owned rather than part of the canonical DSL.

  [ ] 1.4 Section - Phase 1 Integration Tests
    Validate the authored taxonomy, DSL shape, diagnostics, and review output
    end to end inside `unified_ui`.

    [ ] 1.4.1 Task - Authored widget acceptance and rejection scenarios
      Verify the canonical DSL accepts portable widget declarations and rejects
      integration-package leakage.

      [ ] 1.4.1.1 Subtask - Verify authored declarations for every promoted widget validate with the required canonical fields.
      [ ] 1.4.1.2 Subtask - Verify Ash-specific, Phoenix-specific, and renderer-local fields are rejected with actionable diagnostics.
      [ ] 1.4.1.3 Subtask - Verify host-owned form shell examples compile without importing Phoenix or AshPhoenix concepts.

    [ ] 1.4.2 Task - Repeated collection and inspection scenarios
      Verify repeated collection authoring and review output preserve portable
      row-scope meaning.

      [ ] 1.4.2.1 Subtask - Verify repeated collection templates compile with row-scope data references, stable keys, empty states, and child widget bindings.
      [ ] 1.4.2.2 Subtask - Verify invalid relationship-style declarations fail without being lowered into canonical output.
      [ ] 1.4.2.3 Subtask - Verify inspection and export output remains deterministic for promoted widgets and repeated templates.
