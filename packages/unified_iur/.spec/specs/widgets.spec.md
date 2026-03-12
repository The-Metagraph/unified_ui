# Widgets

The widgets layer defines the IUR struct catalog for core controls, navigation/data views, dialogs, feedback, and dynamic form inputs.

```spec-meta
id: unified_iur.widgets
kind: module
status: active
summary: Struct and type contracts for `UnifiedIUR.Widgets` and extension widget modules.
surface:
  - lib/unified_iur/widgets.ex
  - lib/unified_iur/widgets/dialog_feedback.ex
  - lib/unified_iur/widgets/input_widgets.ex
  - lib/unified_iur.ex
  - test/unified_iur_test.exs
```

## Requirements

```spec-requirements
- id: unified_iur.widgets.core_catalog
  statement: The library shall define core widget structs for text, inputs, charts, tabular data, menus, tabs, and tree navigation under `UnifiedIUR.Widgets`.
  priority: must
  stability: stable

- id: unified_iur.widgets.dialog_feedback_catalog
  statement: The library shall define dialog and feedback widgets (`DialogButton`, `Dialog`, `AlertDialog`, `Toast`) with defaults for visibility and interaction behavior.
  priority: must
  stability: stable

- id: unified_iur.widgets.input_builder_catalog
  statement: The library shall define dynamic input widgets (`PickListOption`, `PickList`, `FormField`, `FormBuilder`) that model options/fields separately from containers.
  priority: must
  stability: stable

- id: unified_iur.widgets.top_level_type_aliases
  statement: The top-level `UnifiedIUR` module shall expose type aliases for supported widget structs, including dialog/feedback and input-builder additions.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: unified_iur.widgets.alert_and_toast_defaults
  given:
    - default `AlertDialog` and `Toast` structs
  when:
    - the structs are instantiated without overrides
  then:
    - "alert defaults include `severity: :info`, `modal: true`, and `closable: true`"
    - "toast defaults include `severity: :info`, `duration: 3000`, and `visible: true`"
  covers:
    - unified_iur.widgets.dialog_feedback_catalog
```

## Verification

```spec-verification
- kind: command
  target: mix test test/unified_iur_test.exs
  execute: true
  covers:
    - unified_iur.widgets.core_catalog
    - unified_iur.widgets.dialog_feedback_catalog
    - unified_iur.widgets.input_builder_catalog
    - unified_iur.widgets.top_level_type_aliases
    - unified_iur.widgets.alert_and_toast_defaults
```
