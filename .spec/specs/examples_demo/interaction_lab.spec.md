# Examples Demo Application Interaction Lab

This subject defines the dedicated signal-reactivity tab of the aggregate demo
application where authored controls react to each other's canonical signals.

## Related General Specs

- [Examples Demo Application](./package.spec.md)
- [Examples Demo Application Interface](./interface.spec.md)
- [Example Apps DSL Template](../examples/dsl_template.spec.md)
- [UnifiedUi Signals](../unified-ui/signals.spec.md)
- [UnifiedIUR Interactions](../unified-iur/interactions.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)

```spec-meta
id: repo.examples_demo.interaction_lab
kind: subsystem
status: active
summary: Canonical signal-reactivity contract for the aggregate demo application's dedicated interaction tab.
surface:
  - examples/demo/**
  - .spec/specs/examples_demo/interaction_lab.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: repo.examples_demo.interaction_lab.authored_signal_flow
  statement: The interaction lab shall demonstrate only authored `unified_ui` interactions that compile into canonical `UnifiedIUR` interactions and are translated through the runtime selected for the demo session while preserving canonical event meaning, rather than ad hoc runtime-only event wiring.
  priority: must
  stability: stable

- id: repo.examples_demo.interaction_lab.multiple_signal_families
  statement: The interaction lab shall demonstrate at least `click`, `change`, and `select` or `toggle` interaction families so reviewers can see more than one class of canonical signal behavior.
  priority: must
  stability: stable

- id: repo.examples_demo.interaction_lab.visible_reactive_targets
  statement: Each interaction story shall include a visible target control, panel, or content region that changes meaningfully in response to the emitted signal, such as text, status tone, filtering, selection state, visibility, or chart/metric values.
  priority: must
  stability: stable

- id: repo.examples_demo.interaction_lab.story_panels
  statement: The interaction lab shall present signal stories as named demonstration panels that explain the source control, the emitted intent, and the expected visible outcome before the user interacts.
  priority: must
  stability: stable

- id: repo.examples_demo.interaction_lab.runtime_feedback
  statement: The interaction lab shall show meaningful runtime feedback for the latest interaction, including the signal family or intent and the resulting visible state change, without making raw serialized payload output the only feedback surface.
  priority: must
  stability: stable

- id: repo.examples_demo.interaction_lab.cross_control_examples
  statement: The interaction lab shall include at least one cross-control story where one control changes another control's state or presentation, such as a toggle enabling a secondary input, a select filtering a list or table, or a button changing the status of a feedback panel.
  priority: must
  stability: stable
```

## Minimum Story Inventory

The interaction lab shall include at least these signal-driven story shapes:

- `action_to_feedback`: a button or action control emits a canonical click signal that changes a visible feedback or status region
- `input_to_preview`: a text or numeric input emits a canonical change signal that updates a preview region or bound content panel
- `selection_to_filter`: a select, tabs, menu, or pick-list control emits a selection signal that filters or switches another visible content region
- `toggle_to_visibility_or_enabled_state`: a toggle or checkbox changes whether another control or panel is enabled, visible, or emphasized

## Scenarios

```spec-scenarios
- id: repo.examples_demo.interaction_lab.observe_cross_control_change
  given: A reviewer opens the interaction lab tab
  when: The reviewer uses one story's source control
  then: The reviewer can see another control or panel react visibly and can read a short explanation of the emitted intent and resulting change
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/examples_demo/interaction_lab.spec.md
  covers:
    - repo.examples_demo.interaction_lab.authored_signal_flow
    - repo.examples_demo.interaction_lab.multiple_signal_families
    - repo.examples_demo.interaction_lab.visible_reactive_targets
    - repo.examples_demo.interaction_lab.story_panels
    - repo.examples_demo.interaction_lab.runtime_feedback
    - repo.examples_demo.interaction_lab.cross_control_examples
    - repo.examples_demo.interaction_lab.observe_cross_control_change
```
