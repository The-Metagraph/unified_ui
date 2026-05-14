# UnifiedIUR Widget Components

This subject defines the canonical IUR representation for the widget-component
expansion derived from AshUi PRs 79 through 98.

## Related General Specs

- [Ecosystem Widget Component Behavior](../widget_component_behavior.spec.md)
- [UnifiedIUR Widgets](./widgets.spec.md)
- [UnifiedIUR Constructs](./constructs.spec.md)
- [UnifiedIUR Interactions](./interactions.spec.md)
- [UnifiedUi Widget Components](../unified-ui/widget_components.spec.md)

```spec-meta
id: unified_iur.widget_components
kind: capability
status: active
summary: Canonical IUR contract for expanded widget components and list-repeat composition behavior derived from AshUi PRs 79 through 98.
surface:
  - packages/unified_iur
  - packages/unified_iur/lib/unified_iur/widgets/components.ex
  - .spec/specs/unified-iur/widget_components.spec.md
  - .spec/specs/unified-ui/widget_components.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.canonical_widget_component_expansion
```

## Requirements

```spec-requirements
- id: unified_iur.widget_components.canonical_node_types
  statement: UnifiedIUR shall expose canonical node types or equivalent semantic variants for the expanded widget catalog through `UnifiedIUR.Widgets.Components`, including rich headings, disclosure, runtime-owned forms, kicker labels, avatars, presence indicators, segmented controls, row primitives, progress and stage displays, shell surfaces, callouts, redlines, code blocks, chat composers, and repeated child composition.
  priority: must
  stability: stable

- id: unified_iur.widget_components.content_models
  statement: Each expanded widget representation shall preserve its required content model, including inline text segments, option lists, field lists, columns, title and meta text, trailing or tool children, stage lists, progress segments, redline segments, code token lists, and positional header children.
  priority: must
  stability: stable

- id: unified_iur.widget_components.interaction_descriptors
  statement: Expanded widget representations shall carry renderer-independent interaction descriptors for selection, submit, change, send, row activation, step navigation, disclosure state, slide-over state, and inline actions when those interactions are authored.
  priority: must
  stability: stable

- id: unified_iur.widget_components.accessibility_and_state_metadata
  statement: Expanded widget representations shall preserve accessibility and state metadata such as heading level, labels, aria-like names, active or pressed state, progress value ranges, disabled state, role intent, and open or closed state without forcing one runtime markup model.
  priority: must
  stability: stable

- id: unified_iur.widget_components.text_safety_contract
  statement: UnifiedIUR shall treat redline segment content and code token content as plain text plus semantic token metadata, leaving renderers responsible for safe host output and preventing canonical data from carrying trusted markup by default.
  priority: must
  stability: stable

- id: unified_iur.widget_components.list_repeat_metadata
  statement: UnifiedIUR shall preserve list-repeat composition metadata or deterministic expanded children so that runtimes receive one concrete child node per row with stable identity, row-scoped binding values, and canonical interaction descriptors.
  priority: must
  stability: stable

- id: unified_iur.widget_components.runtime_mapping_completeness
  statement: The expanded widget representations shall provide enough structure for LiveUi, ElmUi, DesktopUi, and TerminalUi renderers to map them into native widgets or documented capability-aware fallbacks without requiring AshUi-specific interpretation.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: unified_iur.widget_components.represent_expanded_widget_tree
  covers:
    - unified_iur.widget_components.canonical_node_types
    - unified_iur.widget_components.content_models
    - unified_iur.widget_components.interaction_descriptors
    - unified_iur.widget_components.accessibility_and_state_metadata
    - unified_iur.widget_components.text_safety_contract
    - unified_iur.widget_components.list_repeat_metadata
    - unified_iur.widget_components.runtime_mapping_completeness
  given:
    - UnifiedUi compiles a screen using the expanded widget-component catalog
  when:
    - The screen is represented as UnifiedIUR
  then:
    - The IUR preserves widget type, content, state, accessibility, interaction, and safety meaning for runtime rendering

- id: unified_iur.widget_components.represent_repeated_rows
  covers:
    - unified_iur.widget_components.list_repeat_metadata
    - unified_iur.widget_components.interaction_descriptors
    - unified_iur.widget_components.runtime_mapping_completeness
  given:
    - A child template repeats over a list binding
  when:
    - UnifiedIUR stores or hydrates the composition
  then:
    - Runtime packages receive deterministic row children rather than an unresolved AshUi relationship directive
```

## Verification

```spec-verification
- kind: source_file
  target: packages/unified_iur/lib/unified_iur/widgets/components.ex
  covers:
    - unified_iur.widget_components.canonical_node_types
    - unified_iur.widget_components.content_models
    - unified_iur.widget_components.interaction_descriptors
    - unified_iur.widget_components.accessibility_and_state_metadata
    - unified_iur.widget_components.text_safety_contract
    - unified_iur.widget_components.runtime_mapping_completeness

- kind: source_file
  target: .spec/specs/unified-iur/widget_components.spec.md
  covers:
    - unified_iur.widget_components.canonical_node_types
    - unified_iur.widget_components.content_models
    - unified_iur.widget_components.interaction_descriptors
    - unified_iur.widget_components.accessibility_and_state_metadata
    - unified_iur.widget_components.text_safety_contract
    - unified_iur.widget_components.list_repeat_metadata
    - unified_iur.widget_components.runtime_mapping_completeness
    - unified_iur.widget_components.represent_expanded_widget_tree
    - unified_iur.widget_components.represent_repeated_rows
```
