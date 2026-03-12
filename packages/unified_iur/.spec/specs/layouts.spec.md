# Layouts

Layouts model container structure and arrangement settings for composing widget trees.

```spec-meta
id: unified_iur.layouts
kind: module
status: active
summary: Contracts for `VBox`/`HBox` containers, supported child unions, and traversal passthrough.
surface:
  - lib/unified_iur/layouts.ex
  - lib/unified_iur/element.ex
  - test/unified_iur_test.exs
```

## Requirements

```spec-requirements
- id: unified_iur.layouts.container_fields
  statement: `VBox` and `HBox` shall define children plus spacing, alignment, justification, padding, style, and visibility fields for layout configuration.
  priority: must
  stability: stable

- id: unified_iur.layouts.child_union_support
  statement: The `UnifiedIUR.Layouts.child` type shall include core widgets, dialog/feedback widgets, input-builder widgets, and nested layouts.
  priority: must
  stability: stable

- id: unified_iur.layouts.element_passthrough
  statement: Element protocol implementations for `VBox` and `HBox` shall return the layout `children` list unchanged for traversal.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: unified_iur.layouts.extension_widgets_in_children
  given:
    - a `VBox` containing a dialog and a pick list
  when:
    - callers inspect both the `children` field and `Element.children/1`
  then:
    - both extension widgets are preserved in order
  covers:
    - unified_iur.layouts.child_union_support
    - unified_iur.layouts.element_passthrough
```

## Verification

```spec-verification
- kind: command
  target: mix test test/unified_iur_test.exs
  execute: true
  covers:
    - unified_iur.layouts.container_fields
    - unified_iur.layouts.child_union_support
    - unified_iur.layouts.element_passthrough
    - unified_iur.layouts.extension_widgets_in_children
```
