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
```

## Scenarios

```spec-scenarios
- id: unified_ui.signals.author_form_interaction
  given: A developer authors a form with change and submit interactions
  when: The authored module is compiled
  then: The package produces canonical signal descriptors that runtime libraries can translate without the author naming renderer-local events

- id: unified_ui.signals.author_navigation_intent
  given: A developer authors a navigation interaction such as opening a dialog, changing a tab, or transitioning to another screen
  when: The interaction is declared in the DSL
  then: The package records canonical event meaning and payload mapping without coupling the author to one renderer runtime
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
    - unified_ui.signals.author_form_interaction
    - unified_ui.signals.author_navigation_intent
```
