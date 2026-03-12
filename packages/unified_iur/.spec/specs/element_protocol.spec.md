# Element Protocol

`UnifiedIUR.Element` defines polymorphic traversal and metadata extraction across all supported IUR element structs.

```spec-meta
id: unified_iur.element_protocol
kind: module
status: active
summary: Traversal and metadata contract for core and extension elements.
surface:
  - lib/unified_iur/element.ex
  - lib/unified_iur/element_helpers.ex
  - lib/unified_iur/widgets/dialog_feedback.ex
  - lib/unified_iur/widgets/input_widgets.ex
  - test/unified_iur_test.exs
```

## Requirements

```spec-requirements
- id: unified_iur.element_protocol.children_contract
  statement: Element protocol implementations shall return child elements for container/composite structs and an empty list for leaf structs.
  priority: must
  stability: stable

- id: unified_iur.element_protocol.metadata_contract
  statement: Element protocol implementations shall return metadata maps containing a stable element type plus renderer-relevant properties.
  priority: must
  stability: stable

- id: unified_iur.element_protocol.any_fallback
  statement: "The protocol shall define an `Any` fallback that returns empty children and metadata with `type: :unknown`."
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: unified_iur.element_protocol.dialog_children_and_metadata
  given:
    - a dialog with nested content and dialog buttons
  when:
    - callers inspect the dialog through `Element.children/1` and `Element.metadata/1`
  then:
    - children preserve content-first ordering followed by configured buttons
    - "metadata reports `type: :dialog` and the dialog lifecycle fields"
  covers:
    - unified_iur.element_protocol.children_contract
    - unified_iur.element_protocol.metadata_contract

- id: unified_iur.element_protocol.pick_list_children_and_metadata
  given:
    - a pick list with explicit options and interactive selection fields
  when:
    - callers inspect the pick list through `Element.children/1` and `Element.metadata/1`
  then:
    - children return the configured option structs
    - metadata reports selection, searchability, and select callback fields
  covers:
    - unified_iur.element_protocol.children_contract
    - unified_iur.element_protocol.metadata_contract

- id: unified_iur.element_protocol.form_builder_children_and_metadata
  given:
    - a form builder with multiple field descriptors and submit configuration
  when:
    - callers inspect the form builder through `Element.children/1` and `Element.metadata/1`
  then:
    - children return field descriptors in declaration order
    - metadata reports action, submit callback, and submit label fields
  covers:
    - unified_iur.element_protocol.children_contract
    - unified_iur.element_protocol.metadata_contract
```

## Verification

```spec-verification
- kind: command
  target: mix test test/unified_iur_test.exs
  execute: true
  covers:
    - unified_iur.element_protocol.any_fallback
    - unified_iur.element_protocol.children_contract
    - unified_iur.element_protocol.metadata_contract
    - unified_iur.element_protocol.dialog_children_and_metadata
    - unified_iur.element_protocol.pick_list_children_and_metadata
    - unified_iur.element_protocol.form_builder_children_and_metadata
```
