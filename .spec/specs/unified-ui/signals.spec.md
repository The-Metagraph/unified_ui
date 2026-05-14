# UnifiedUi Signals

This subject defines how `unified_ui` authors and compiles canonical interaction
descriptors for the ecosystem event boundary.

## Related General Specs

- [Signal Transport](../signal_transport.spec.md)
- [Ecosystem Architecture](../architecture.spec.md)
- [UnifiedUi Package](./package.spec.md)
- [UnifiedUi DSL](./dsl.spec.md)
- [UnifiedUi Compiler](./compiler.spec.md)

```spec-meta
id: unified_ui.signals
kind: integration
status: active
summary: Target signal authoring and compilation contract for canonical `unified_ui` interaction descriptors.
surface:
  - packages/unified-ui
  - .spec/specs/unified-ui/signals.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.canonical_navigation_boundary
```

## Requirements

```spec-requirements
- id: unified_ui.signals.canonical_descriptor_shape
  statement: The package shall author interaction bindings in a canonical descriptor shape that can be translated into `Jido.Signal` and CloudEvents-compatible boundary semantics by runtime libraries.
  priority: must
  stability: stable

- id: unified_ui.signals.authoring_event_semantics
  statement: Authored interaction bindings shall describe event meaning in terms of canonical event type, source context, target intent, and payload mapping rather than runtime-library callback names.
  priority: must
  stability: stable

- id: unified_ui.signals.standard_interaction_families
  statement: The package shall provide standard canonical interaction families for user actions such as click, change, submit, open, close, focus, selection, navigation, and command-oriented interaction patterns.
  priority: must
  stability: stable

- id: unified_ui.signals.validation_and_introspection
  statement: The package shall validate authored signal descriptors and expose helper surfaces that let developers inspect supported interaction families and compiled signal shapes.
  priority: must
  stability: stable

- id: unified_ui.signals.no_runtime_local_event_leakage
  statement: The authored signal surface shall not require `elm_ui`, `live_ui`, or `desktop_ui` local event names, local payload keys, or local transport envelopes in authored modules.
  priority: must
  stability: stable

- id: unified_ui.signals.navigation_transition_actions
  statement: The authored navigation interaction surface shall support canonical screen-transition actions such as `navigate_to`, `replace_with`, `go_back`, `go_forward`, `open_modal`, and `close_modal` without requiring host-router syntax.
  priority: must
  stability: stable

- id: unified_ui.signals.navigation_symbolic_screen_targets
  statement: When a navigation interaction changes the active top-level surface, the authoring model shall express the target as a symbolic screen identifier with optional params or metadata rather than URLs, Phoenix route helpers, runtime modules, or browser-history instructions.
  priority: must
  stability: stable

- id: unified_ui.signals.navigation_modal_stack_semantics
  statement: The authored navigation interaction surface shall model nested modal flows as stack transitions; `open_modal` pushes a symbolic modal target onto the current modal stack, and `close_modal` closes the topmost modal by default or a named open modal when a modal target is supplied, without requiring modal definitions to be structurally contained inside one another.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: unified_ui.signals.author_form_interaction
  covers:
    - unified_ui.signals.canonical_descriptor_shape
    - unified_ui.signals.authoring_event_semantics
    - unified_ui.signals.standard_interaction_families
    - unified_ui.signals.validation_and_introspection
    - unified_ui.signals.no_runtime_local_event_leakage
    - unified_ui.signals.navigation_transition_actions
    - unified_ui.signals.navigation_symbolic_screen_targets
  given:
    - A developer authors a form with change and submit interactions
  when:
    - The authored module is compiled
  then:
    - The package produces canonical signal descriptors that runtime libraries can translate without the author naming renderer-local events

- id: unified_ui.signals.author_navigation_intent
  covers:
    - unified_ui.signals.canonical_descriptor_shape
    - unified_ui.signals.authoring_event_semantics
    - unified_ui.signals.standard_interaction_families
    - unified_ui.signals.validation_and_introspection
    - unified_ui.signals.no_runtime_local_event_leakage
    - unified_ui.signals.navigation_transition_actions
    - unified_ui.signals.navigation_symbolic_screen_targets
    - unified_ui.signals.navigation_modal_stack_semantics
  given:
    - A developer authors a navigation interaction such as opening a dialog, changing a tab, or transitioning to another screen
  when:
    - The interaction is declared in the DSL
  then:
    - The package records canonical event meaning and payload mapping without coupling the author to one renderer runtime

- id: unified_ui.signals.author_stacked_modal_navigation_intent
  covers:
    - unified_ui.signals.canonical_descriptor_shape
    - unified_ui.signals.authoring_event_semantics
    - unified_ui.signals.standard_interaction_families
    - unified_ui.signals.validation_and_introspection
    - unified_ui.signals.no_runtime_local_event_leakage
    - unified_ui.signals.navigation_transition_actions
    - unified_ui.signals.navigation_symbolic_screen_targets
    - unified_ui.signals.navigation_modal_stack_semantics
  given:
    - A developer authors a modal flow where one modal can open another modal
  when:
    - The interactions are declared as consecutive `open_modal` and `close_modal` navigation actions
  then:
    - The package records stack-based modal transition meaning, including topmost close behavior, without requiring nested modal structural containment
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/unified-ui/signals.spec.md
  covers:
    - unified_ui.signals.canonical_descriptor_shape
    - unified_ui.signals.authoring_event_semantics
    - unified_ui.signals.standard_interaction_families
    - unified_ui.signals.validation_and_introspection
    - unified_ui.signals.no_runtime_local_event_leakage
    - unified_ui.signals.navigation_transition_actions
    - unified_ui.signals.navigation_symbolic_screen_targets
    - unified_ui.signals.navigation_modal_stack_semantics
    - unified_ui.signals.author_form_interaction
    - unified_ui.signals.author_navigation_intent
    - unified_ui.signals.author_stacked_modal_navigation_intent
```
