# Phase 1 - Canonical Catalog and UnifiedUi Authoring Surface

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `UnifiedUi.Dsl`
- `UnifiedUi.Compiler`
- `UnifiedUi.Signal`
- `UnifiedUi.Tooling`
- `UnifiedIUR.Element`
- `UnifiedIUR.Interaction`

## Relevant Assumptions / Defaults
- The AshUi PR names are source references, not automatically canonical names.
- Host-neutral names are preferred when an AshUi name leaks a runtime, such as
  `phoenix_form`.
- The expanded catalog must compile to UnifiedIUR rather than renderer-specific
  output.
- List-repeat behavior is composition behavior, not a widget renderer escape
  hatch.
- All work in this phase is not done.

[ ] 1 Phase 1 - Canonical Catalog and UnifiedUi Authoring Surface
  Define the portable catalog and authored DSL surface for the PR 79-98 widget
  additions so UnifiedUi can express the new components and list-repeat
  behavior without depending on AshUi or runtime package APIs.

  [x] 1.1 Section - Catalog Taxonomy and Canonical Naming
    Establish the portable naming, semantic families, and compatibility policy
    for the expanded widget-component catalog before adding authored DSL entry
    points.

    [x] 1.1.1 Task - Define the canonical widget family taxonomy
      Group the AshUi PR set into stable families that match how authors and
      runtimes will reason about the catalog.

      [x] 1.1.1.1 Subtask - Classify content and identity widgets: `inline_rich_text_heading`, `kicker`, `avatar`, `presence_dot`, and `disclosure`.
      [x] 1.1.1.2 Subtask - Classify form and control widgets: runtime-owned form shell, `segmented_button_group`, and `chat_composer`.
      [x] 1.1.1.3 Subtask - Classify list, artifact, workflow, progress, layer, callout, redline, and code widgets into implementation families.
      [x] 1.1.1.4 Subtask - Record the PR 79-98 source mapping in package docs or tooling output so the adoption history is discoverable.

    [x] 1.1.2 Task - Define canonical names and AshUi compatibility aliases
      Keep the canonical surface portable while allowing explicit aliases where
      that reduces migration friction.

      [x] 1.1.2.1 Subtask - Define the canonical name for the `phoenix_form` equivalent as a runtime-owned form shell.
      [x] 1.1.2.2 Subtask - Decide which AshUi names can be accepted as authoring aliases without making AshUi part of the contract.
      [x] 1.1.2.3 Subtask - Add validation diagnostics that identify deprecated or host-specific aliases and point authors to canonical names.

  [x] 1.2 Section - Content, Identity, and Disclosure Authoring
    Add authored DSL support for the passive and identity-oriented components
    whose behavior is mostly content, state, accessibility, and child
    composition.

    [x] 1.2.1 Task - Implement rich heading and kicker authoring
      Support editorial heading and eyebrow-label patterns with deterministic
      content models.

      [x] 1.2.1.1 Subtask - Author `inline_rich_text_heading` with heading level and inline `text` or `emphasis` segment validation.
      [x] 1.2.1.2 Subtask - Author `kicker` with ordered items and separator behavior.
      [x] 1.2.1.3 Subtask - Reject invalid heading levels, malformed segments, and non-string kicker items with actionable diagnostics.

    [x] 1.2.2 Task - Implement avatar, presence, and disclosure authoring
      Support identity display, small status signals, and native progressive
      disclosure in the authored catalog.

      [x] 1.2.2.1 Subtask - Author `avatar` with initials, optional image source, shape, size, variant, and accessible label.
      [x] 1.2.2.2 Subtask - Author `presence_dot` with state, size, and optional accessible label.
      [x] 1.2.2.3 Subtask - Author `disclosure` with summary text, initial open state, and child body content.

  [x] 1.3 Section - Form, Control, and Composer Authoring
    Add authored DSL support for controls that carry canonical interaction
    meaning while leaving host-specific form lifecycle ownership to runtimes.

    [x] 1.3.1 Task - Implement segmented button group authoring
      Support single-selection segmented controls with option identity and
      canonical selection intent.

      [x] 1.3.1.1 Subtask - Author options with value and label fields.
      [x] 1.3.1.2 Subtask - Author active option state and optional disabled state.
      [x] 1.3.1.3 Subtask - Lower selection intent into canonical interaction descriptors rather than renderer-local event names.

    [x] 1.3.2 Task - Implement runtime-owned form shell authoring
      Represent the `phoenix_form` PR meaning portably without making Phoenix
      the ecosystem contract.

      [x] 1.3.2.1 Subtask - Author form fields, submit label, submit intent, change intent, validation state, and field attributes.
      [x] 1.3.2.2 Subtask - Document that runtime-owned form state is owned by the host runtime or application, not by canonical IUR.
      [x] 1.3.2.3 Subtask - Add LiveUi-facing metadata hooks for Phoenix or AshPhoenix integration without leaking them into the canonical contract.

    [x] 1.3.3 Task - Implement chat composer authoring
      Support multi-line composer authoring with text input, tool children, and
      canonical send and change events.

      [x] 1.3.3.1 Subtask - Author text value, placeholder, rows, disabled state, send label, and send intent.
      [x] 1.3.3.2 Subtask - Author optional tool-area and status children with deterministic ordering.
      [x] 1.3.3.3 Subtask - Validate that send and change interactions preserve canonical event meaning.

  [x] 1.4 Section - Rows, Workflow, Layer, Callout, Redline, and Code Authoring
    Add authored DSL support for the remaining visual and operational widget
    families in the PR set.

    [x] 1.4.1 Task - Implement row and artifact authoring
      Support selectable or linkable row primitives for list and artifact
      surfaces.

      [x] 1.4.1.1 Subtask - Author `list_item_multi_column` with row identity, column template, active state, optional link target, and child cells.
      [x] 1.4.1.2 Subtask - Author `artifact_row` with title, meta, row identity, active state, optional link target, and trailing children.
      [x] 1.4.1.3 Subtask - Lower row activation into canonical interaction descriptors.

    [x] 1.4.2 Task - Implement workflow and progress authoring
      Support the stage, progress, and meter widgets needed by process and
      workflow screens.

      [x] 1.4.2.1 Subtask - Author `pipeline_stepper_horizontal` with ordered steps, active index, completed state, labels, and optional navigation intent.
      [x] 1.4.2.2 Subtask - Author `segmented_progress_bar` with segment weights, states, labels, and aggregate progress metadata.
      [x] 1.4.2.3 Subtask - Author `workflow_stage_list_vertical` and `meter_thin` with normalized values, labels, and state semantics.

    [x] 1.4.3 Task - Implement layer, shell, callout, redline, and code authoring
      Support shell and content-specialized widgets with portable structure and
      safety rules.

      [x] 1.4.3.1 Subtask - Author `sticky_frosted_header` with leading, title, and trailing positional children.
      [x] 1.4.3.2 Subtask - Author `slide_over_panel` as a non-modal layer with open state, size, label, and children.
      [x] 1.4.3.3 Subtask - Author `event_callout`, `redline_inline`, and `code_block_syntax_highlighted` with tone, segment, token, and text-safety metadata.

  [x] 1.5 Section - List-Repeat Composition Authoring
    Add the list-repeat behavior introduced by AshUi PR 98 as a canonical DSL
    composition primitive.

    [x] 1.5.1 Task - Define repeat composition syntax and validation
      Establish how authors attach a child template to rows from a list
      binding.

      [x] 1.5.1.1 Subtask - Define the authored repeat directive shape and how it references a list binding.
      [x] 1.5.1.2 Subtask - Validate that repeat can only target list-like bindings and compatible child templates.
      [x] 1.5.1.3 Subtask - Validate row-scope binding references and reject unsupported deep or host-specific row access until explicitly supported.

    [x] 1.5.2 Task - Expose repeat inspection and diagnostics
      Make repeated composition visible and debuggable before runtime rendering.

      [x] 1.5.2.1 Subtask - Add inspection output for repeat binding id, row scope, template identity, and generated identity strategy.
      [x] 1.5.2.2 Subtask - Add diagnostics for missing list bindings, malformed row fields, and repeat use on single-child composition.
      [x] 1.5.2.3 Subtask - Add authoring examples that show repeated artifact rows and repeated event callouts.

  [ ] 1.6 Section - Phase 1 Integration Tests
    Validate the authored DSL surface, alias policy, diagnostics, and repeat
    authoring before compiler and IUR work begins.

    [ ] 1.6.1 Task - Catalog authoring scenarios
      Verify representative components from each family compile through the
      authored DSL validation layer.

      [ ] 1.6.1.1 Subtask - Verify content, identity, row, workflow, layer, form, composer, redline, and code widgets are accepted with valid authored fields.
      [ ] 1.6.1.2 Subtask - Verify malformed fields are rejected with diagnostics that name the canonical widget and field.
      [ ] 1.6.1.3 Subtask - Verify host-specific aliases, if accepted, are reported as aliases rather than canonical names.

    [ ] 1.6.2 Task - Repeat authoring scenarios
      Verify list-repeat authoring validates data shape and exposes useful
      inspection output.

      [ ] 1.6.2.1 Subtask - Verify a repeated artifact-row template over a list binding validates successfully.
      [ ] 1.6.2.2 Subtask - Verify repeat rejects non-list bindings and missing row-scope fields.
      [ ] 1.6.2.3 Subtask - Verify inspection output shows repeat metadata deterministically.
