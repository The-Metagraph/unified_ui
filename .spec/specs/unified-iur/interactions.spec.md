# UnifiedIUR Interactions

This subject defines how canonical interaction and data-binding intent is
represented inside `unified_iur`.

## Related General Specs

- [Signal Transport](../signal_transport.spec.md)
- [DSL and IUR Symbiosis](../dsl_iur_symbiosis.spec.md)
- [UnifiedIUR Package](./package.spec.md)
- [UnifiedIUR Core](./core.spec.md)

```spec-meta
id: unified_iur.interactions
kind: integration
status: active
summary: Target contract for representing canonical interaction descriptors, binding intent, and event metadata inside `unified_iur`.
surface:
  - packages/unified_iur
  - .spec/specs/unified-iur/interactions.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.canonical_navigation_boundary
```

## Requirements

```spec-requirements
- id: unified_iur.interactions.canonical_event_descriptor_representation
  statement: The package shall represent canonical interaction descriptors in a form that preserves authored event meaning and can be translated by runtime libraries into `Jido.Signal` and CloudEvents-compatible boundary behavior.
  priority: must
  stability: stable

- id: unified_iur.interactions.element_binding_attachment
  statement: Canonical widgets and composite constructs shall be able to carry interaction bindings, action intent, and data-binding metadata needed for runtime interpretation.
  priority: must
  stability: stable

- id: unified_iur.interactions.renderer_independent_payload_mapping
  statement: Interaction descriptors shall encode payload mapping, source context, and target intent without embedding renderer-local event names, transport envelopes, or runtime-specific callback logic.
  priority: must
  stability: stable

- id: unified_iur.interactions.standard_interaction_families
  statement: The package shall be able to represent standard canonical interaction families such as change, submit, click, open, close, selection, focus, navigation, and command-oriented interactions when they are authored through `unified_ui`.
  priority: must
  stability: stable

- id: unified_iur.interactions.data_binding_representation
  statement: The package shall represent dynamic data references, bound values, and authored dependency relationships needed for runtime libraries to reconstruct current UI meaning from canonical IUR.
  priority: must
  stability: stable

- id: unified_iur.interactions.navigation_transition_representation
  statement: The package shall represent canonical screen-transition descriptors including transition action, symbolic screen target, modal target, and params in a renderer-independent form.
  priority: must
  stability: stable

- id: unified_iur.interactions.no_host_router_assumptions
  statement: Canonical navigation descriptors shall not encode browser path syntax, host-router names, or runtime-module references as the cross-runtime navigation contract.
  priority: must
  stability: stable

- id: unified_iur.interactions.modal_stack_transition_semantics
  statement: Canonical navigation descriptors shall represent nested modal flows as ordered modal stack transitions; `open_modal` adds a symbolic modal target to the active modal stack, targetless `close_modal` removes the topmost modal, and targeted `close_modal` identifies a named open modal without requiring modal definitions to be structurally nested.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: unified_iur.interactions.form_submission_descriptor
  covers:
    - unified_iur.interactions.canonical_event_descriptor_representation
    - unified_iur.interactions.element_binding_attachment
    - unified_iur.interactions.renderer_independent_payload_mapping
    - unified_iur.interactions.standard_interaction_families
    - unified_iur.interactions.data_binding_representation
    - unified_iur.interactions.navigation_transition_representation
    - unified_iur.interactions.no_host_router_assumptions
    - unified_iur.interactions.modal_stack_transition_semantics
  given:
    - A canonical form contains input bindings and submit actions
  when:
    - The form is compiled into `unified_iur`
  then:
    - The form elements carry canonical interaction descriptors and data-binding references without depending on any one runtime-library event model

- id: unified_iur.interactions.stacked_modal_transition_descriptor
  covers:
    - unified_iur.interactions.canonical_event_descriptor_representation
    - unified_iur.interactions.element_binding_attachment
    - unified_iur.interactions.renderer_independent_payload_mapping
    - unified_iur.interactions.standard_interaction_families
    - unified_iur.interactions.navigation_transition_representation
    - unified_iur.interactions.no_host_router_assumptions
    - unified_iur.interactions.modal_stack_transition_semantics
  given:
    - Canonical interactions describe opening one modal from another modal
  when:
    - The interactions are represented in IUR
  then:
    - The descriptors preserve ordered modal stack actions and symbolic modal targets without embedding renderer-local containment or routing data
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/unified-iur/interactions.spec.md
  covers:
    - unified_iur.interactions.canonical_event_descriptor_representation
    - unified_iur.interactions.element_binding_attachment
    - unified_iur.interactions.renderer_independent_payload_mapping
    - unified_iur.interactions.standard_interaction_families
    - unified_iur.interactions.data_binding_representation
    - unified_iur.interactions.navigation_transition_representation
    - unified_iur.interactions.no_host_router_assumptions
    - unified_iur.interactions.modal_stack_transition_semantics
    - unified_iur.interactions.form_submission_descriptor
    - unified_iur.interactions.stacked_modal_transition_descriptor
```
