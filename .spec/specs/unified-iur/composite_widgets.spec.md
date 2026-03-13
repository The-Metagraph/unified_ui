# UnifiedIUR Composite Widgets

This subject backfills the current composite widget surface of
`packages/unified_iur`, covering dialog/feedback and form-oriented widget
families defined outside the base widgets module.

```spec-meta
id: unified_iur.composite_widgets
kind: subsystem
status: active
summary: Current composite widget contract for dialogs, feedback widgets, pick lists, and form builders in `packages/unified_iur`.
surface:
  - packages/unified_iur/lib/unified_iur/widgets/dialog_feedback.ex
  - packages/unified_iur/lib/unified_iur/widgets/input_widgets.ex
  - packages/unified_iur/test/unified_iur_test.exs
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: unified_iur.composite_widgets.dialog_and_feedback
  statement: The package shall define the current dialog and feedback structs for dialog_button, dialog, alert_dialog, and toast, including the current nested-child and metadata behavior exposed through the element protocol.
  priority: must
  stability: stable

- id: unified_iur.composite_widgets.form_and_selection
  statement: The package shall define the current selection and form-building structs for pick_list_option, pick_list, form_field, and form_builder, including the current nested-child and metadata behavior exposed through the element protocol.
  priority: must
  stability: stable

- id: unified_iur.composite_widgets.layout_compatibility
  statement: The current composite widget structs shall remain usable as layout children through the existing IUR child model exercised by the package tests.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/unified_iur/lib/unified_iur/widgets/dialog_feedback.ex
  covers:
    - unified_iur.composite_widgets.dialog_and_feedback

- kind: source_file
  target: packages/unified_iur/lib/unified_iur/widgets/input_widgets.ex
  covers:
    - unified_iur.composite_widgets.form_and_selection

- kind: source_file
  target: packages/unified_iur/test/unified_iur_test.exs
  covers:
    - unified_iur.composite_widgets.dialog_and_feedback
    - unified_iur.composite_widgets.form_and_selection
    - unified_iur.composite_widgets.layout_compatibility
```
