# Phase 4 - Widget Catalog Parity and Registry Foundation

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `WebUi.WidgetRegistry`
- `WebUi.Widget`
- `WidgetDescriptor`
- `WidgetRenderRequest`
- `WidgetRenderResult`

## Relevant Assumptions / Defaults
- Built-in widget catalog parity with `term_ui` is normative.
- Descriptor metadata is required for every built-in widget.
- Render behavior must be deterministic for equivalent inputs.

[x] 4 Phase 4 - Widget Catalog Parity and Registry Foundation
  Implement the built-in widget system baseline so catalog parity, descriptor completeness, and deterministic render contracts are enforceable.

  [x] 4.1 Section - Built-in Catalog Parity Baseline
    Implement the built-in registry entries required by `widget_system_contract.md`.

    [x] 4.1.1 Task - Implement full built-in widget ID catalog
      Register all required primitive and composite widget IDs as built-ins.

      [x] 4.1.1.1 Subtask - Implement primitive widget registration entries.
      [x] 4.1.1.2 Subtask - Implement composite widget registration entries.
      [x] 4.1.1.3 Subtask - Implement startup parity check against required baseline IDs.

    [x] 4.1.2 Task - Implement stable ID and category policy
      Enforce stable widget IDs and category classifications across release lines.

      [x] 4.1.2.1 Subtask - Implement immutable built-in ID mapping structure.
      [x] 4.1.2.2 Subtask - Implement descriptor category assignment validation.
      [x] 4.1.2.3 Subtask - Implement policy guardrails against accidental ID churn.

  [x] 4.2 Section - Descriptor and Schema Completeness
    Implement descriptor-level metadata requirements for props and event schemas.

    [x] 4.2.1 Task - Implement required `WidgetDescriptor` fields for built-ins
      Ensure all built-ins publish complete and valid descriptor metadata.

      [x] 4.2.1.1 Subtask - Implement required descriptor field checks for ID, category, and version.
      [x] 4.2.1.2 Subtask - Implement props schema declaration requirements for built-ins.
      [x] 4.2.1.3 Subtask - Implement event schema declaration requirements linked to event catalog types.

    [x] 4.2.2 Task - Implement descriptor query and inspection APIs
      Provide deterministic lookup surfaces for runtime and tooling consumers.

      [x] 4.2.2.1 Subtask - Implement descriptor lookup by widget ID.
      [x] 4.2.2.2 Subtask - Implement filtered list queries by category and origin.
      [x] 4.2.2.3 Subtask - Implement missing-descriptor error behavior with typed outcomes.

  [x] 4.3 Section - Deterministic Render Contract Baseline
    Implement baseline render request/result behavior for built-in widgets.

    [x] 4.3.1 Task - Implement render-request validation and shaping
      Validate render requests before widget execution and normalize request forms.

      [x] 4.3.1.1 Subtask - Implement required field validation for `WidgetRenderRequest`.
      [x] 4.3.1.2 Subtask - Implement props/state schema validation hooks.
      [x] 4.3.1.3 Subtask - Implement fail-closed typed errors for invalid render requests.

    [x] 4.3.2 Task - Implement render-result normalization and lifecycle events
      Normalize render outcomes and emit required widget lifecycle events.

      [x] 4.3.2.1 Subtask - Implement `WidgetRenderResult` success/error shaping rules.
      [x] 4.3.2.2 Subtask - Implement required render lifecycle event emission.
      [x] 4.3.2.3 Subtask - Implement correlation metadata continuity for widget lifecycle events.

  [x] 4.4 Section - Phase 4 Integration Tests
    Validate built-in parity, descriptor completeness, and deterministic render behavior end-to-end.

    [x] 4.4.1 Task - Catalog and descriptor integration scenarios
      Verify baseline widget coverage and descriptor metadata completeness.

      [x] 4.4.1.1 Subtask - Verify built-in catalog matches required baseline widget IDs exactly.
      [x] 4.4.1.2 Subtask - Verify each built-in widget has complete descriptor schema metadata.
      [x] 4.4.1.3 Subtask - Verify descriptor query APIs return deterministic results.

    [x] 4.4.2 Task - Render determinism integration scenarios
      Verify equivalent inputs produce equivalent outputs and typed failures remain stable.

      [x] 4.4.2.1 Subtask - Verify repeated equivalent render requests produce equivalent render outputs.
      [x] 4.4.2.2 Subtask - Verify invalid render requests fail with typed validation errors.
      [x] 4.4.2.3 Subtask - Verify render lifecycle events include required correlation metadata.
