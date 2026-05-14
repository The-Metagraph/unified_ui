# Widget Component Behavior

This subject defines the ecosystem-level behavior contract for the canonical
widget-component expansion derived from AshUi PRs 79 through 98.

## Related General Specs

- [Ecosystem Architecture](./architecture.spec.md)
- [DSL and IUR Symbiosis](./dsl_iur_symbiosis.spec.md)
- [Platform Runtimes](./platform_runtimes.spec.md)
- [Signal Transport](./signal_transport.spec.md)
- [UnifiedUi Widget Components](./unified-ui/widget_components.spec.md)
- [UnifiedIUR Widget Components](./unified-iur/widget_components.spec.md)

```spec-meta
id: ecosystem.widget_component_behavior
kind: integration
status: active
summary: Cross-package behavior contract for the canonical widget-component catalog and list-repeat composition behavior derived from AshUi PRs 79 through 98.
surface:
  - packages/unified-ui
  - packages/unified_iur
  - packages/live_ui
  - packages/elm_ui
  - packages/desktop_ui
  - packages/terminal_ui
  - .spec/specs/widget_component_behavior.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.canonical_widget_component_expansion
```

## Requirements

```spec-requirements
- id: ecosystem.widget_component_behavior.ash_ui_pr_79_98_equivalents
  statement: The ecosystem shall provide canonical equivalents for the AshUi PR 79-98 additions, including inline rich text headings, disclosure, runtime-owned forms, kicker labels, avatars, presence indicators, segmented controls, multi-column list rows, artifact rows, sticky headers, workflow steppers, segmented progress, vertical stage lists, thin meters, slide-over panels, event callouts, inline redlines, pre-tokenized code blocks, chat composers, and list-repeat composition.
  priority: must
  stability: stable

- id: ecosystem.widget_component_behavior.semantic_families
  statement: The expanded widget-component catalog shall be grouped into portable semantic families for content and identity, form and composer controls, list and artifact rows, workflow and progress status, layer and shell surfaces, and code or redline text display.
  priority: must
  stability: stable

- id: ecosystem.widget_component_behavior.host_specific_names_do_not_define_canonical_meaning
  statement: Host-specific AshUi names or implementation details shall not define the canonical ecosystem meaning; for example, the AshUi `phoenix_form` concept shall be represented canonically as a runtime-owned form shell with LiveUi-specific Phoenix realization.
  priority: must
  stability: stable

- id: ecosystem.widget_component_behavior.list_repeat_is_composition_behavior
  statement: List-repeat support shall be treated as canonical composition behavior that binds a child template to rows from a list binding and produces deterministic child element instances before runtime rendering.
  priority: must
  stability: stable

- id: ecosystem.widget_component_behavior.interaction_meaning_preserved
  statement: Widget interactions shall preserve canonical event meaning for selection, submit, change, send, row activation, step navigation, disclosure state, panel state, and action affordances without embedding renderer-local callback names as the cross-package contract.
  priority: must
  stability: stable

- id: ecosystem.widget_component_behavior.accessibility_and_safety_preserved
  statement: Widget realizations shall preserve applicable accessibility roles, labels, state attributes, and text-safety rules, including escaping plain-text code and redline content before any runtime emits markup or host-native rich text.
  priority: must
  stability: stable

- id: ecosystem.widget_component_behavior.runtime_native_and_iur_parity
  statement: LiveUi, ElmUi, DesktopUi, and TerminalUi shall expose native equivalents for the expanded widget-component catalog and shall also map canonical UnifiedIUR input into those same native meanings.
  priority: must
  stability: stable

- id: ecosystem.widget_component_behavior.capability_aware_degradation
  statement: Runtime packages with limited display or interaction capabilities shall use explicit degradation policies for the expanded catalog while preserving core structure, state, accessibility, and interaction meaning.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: ecosystem.widget_component_behavior.render_document_workflow_surface
  covers:
    - ecosystem.widget_component_behavior.ash_ui_pr_79_98_equivalents
    - ecosystem.widget_component_behavior.semantic_families
    - ecosystem.widget_component_behavior.interaction_meaning_preserved
    - ecosystem.widget_component_behavior.runtime_native_and_iur_parity
  given:
    - A document-workflow screen contains artifact rows, event callouts, redline text, code blocks, progress indicators, a slide-over panel, and a chat composer
  when:
    - The screen is authored in UnifiedUi and rendered through a runtime package
  then:
    - The runtime realizes the same canonical widget meanings without falling back to AshUi-specific widgets or renderer-local escape hatches

- id: ecosystem.widget_component_behavior.expand_list_repeat_rows
  covers:
    - ecosystem.widget_component_behavior.list_repeat_is_composition_behavior
    - ecosystem.widget_component_behavior.interaction_meaning_preserved
    - ecosystem.widget_component_behavior.accessibility_and_safety_preserved
  given:
    - An authored child template is repeated over a list binding
  when:
    - The compiler and IUR hydration pipeline resolve the screen
  then:
    - The runtime receives deterministic child element instances with row-scoped data and canonical interactions already preserved

- id: ecosystem.widget_component_behavior.degrade_to_terminal
  covers:
    - ecosystem.widget_component_behavior.runtime_native_and_iur_parity
    - ecosystem.widget_component_behavior.capability_aware_degradation
    - ecosystem.widget_component_behavior.accessibility_and_safety_preserved
  given:
    - The expanded catalog is rendered in a limited terminal profile
  when:
    - Visual effects such as frost, slide animation, color-rich progress, or multi-column spacing are unavailable
  then:
    - TerminalUi applies explicit readable fallbacks while preserving state, labels, actions, and event meaning
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/widget_component_behavior.spec.md
  covers:
    - ecosystem.widget_component_behavior.ash_ui_pr_79_98_equivalents
    - ecosystem.widget_component_behavior.semantic_families
    - ecosystem.widget_component_behavior.host_specific_names_do_not_define_canonical_meaning
    - ecosystem.widget_component_behavior.list_repeat_is_composition_behavior
    - ecosystem.widget_component_behavior.interaction_meaning_preserved
    - ecosystem.widget_component_behavior.accessibility_and_safety_preserved
    - ecosystem.widget_component_behavior.runtime_native_and_iur_parity
    - ecosystem.widget_component_behavior.capability_aware_degradation
    - ecosystem.widget_component_behavior.render_document_workflow_surface
    - ecosystem.widget_component_behavior.expand_list_repeat_rows
    - ecosystem.widget_component_behavior.degrade_to_terminal
```
