# UnifiedUi Widget Components

This subject defines the authored UnifiedUi surface for the canonical
widget-component expansion derived from AshUi PRs 79 through 98.

## Related General Specs

- [Ecosystem Widget Component Behavior](../widget_component_behavior.spec.md)
- [UnifiedUi Widgets](./widgets.spec.md)
- [UnifiedUi DSL](./dsl.spec.md)
- [UnifiedUi Compiler](./compiler.spec.md)
- [UnifiedIUR Widget Components](../unified-iur/widget_components.spec.md)

```spec-meta
id: unified_ui.widget_components
kind: subsystem
status: active
summary: Authored DSL contract for canonical widget components and list-repeat composition behavior derived from AshUi PRs 79 through 98.
surface:
  - packages/unified-ui
  - .spec/specs/unified-ui/widget_components.spec.md
  - .spec/specs/unified-iur/widget_components.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.canonical_widget_component_expansion
```

## Requirements

```spec-requirements
- id: unified_ui.widget_components.content_identity_and_disclosure_surface
  statement: The DSL shall author content and identity components equivalent to `inline_rich_text_heading`, `kicker`, `avatar`, `presence_dot`, and `disclosure`, preserving heading level, inline emphasis segments, label clusters, identity imagery or initials, presence state, and disclosure open-state semantics.
  priority: must
  stability: stable

- id: unified_ui.widget_components.form_control_and_composer_surface
  statement: The DSL shall author form and composer controls equivalent to `segmented_button_group`, `phoenix_form` as a runtime-owned form shell, and `chat_composer`, preserving single-selection options, submit and change intent, textarea value and disabled state, tool-area children, and send intent.
  priority: must
  stability: stable

- id: unified_ui.widget_components.row_and_artifact_surface
  statement: The DSL shall author row-oriented components equivalent to `list_item_multi_column` and `artifact_row`, preserving selectable or linkable row identity, active state, column or title/meta structure, and trailing child content.
  priority: must
  stability: stable

- id: unified_ui.widget_components.workflow_progress_and_status_surface
  statement: The DSL shall author workflow and progress components equivalent to `pipeline_stepper_horizontal`, `segmented_progress_bar`, `workflow_stage_list_vertical`, and `meter_thin`, preserving stage order, done or active or pending state, weighted segment state, value normalization, labels, and optional navigation intent.
  priority: must
  stability: stable

- id: unified_ui.widget_components.layer_shell_and_callout_surface
  statement: The DSL shall author shell, layer, and callout components equivalent to `sticky_frosted_header`, `slide_over_panel`, and `event_callout`, preserving positional header slots, non-modal slide-over open state and sizing, callout tone, body, eyebrow, and inline action composition.
  priority: must
  stability: stable

- id: unified_ui.widget_components.redline_and_code_surface
  statement: The DSL shall author text-display components equivalent to `redline_inline` and `code_block_syntax_highlighted`, preserving redline keep, insert, delete, accepted, and rejected states plus pre-tokenized code language and token-type data without making the DSL a syntax highlighter.
  priority: must
  stability: stable

- id: unified_ui.widget_components.list_repeat_authoring
  statement: The DSL shall author list-repeat composition behavior that attaches a child template to a list binding, validates row-scope binding references, rejects repeat use against non-list composition, and compiles deterministic row-expanded canonical output.
  priority: must
  stability: stable

- id: unified_ui.widget_components.portable_names_and_aliases
  statement: The DSL shall document portable canonical names for host-neutral concepts and may provide AshUi-name aliases only when aliases do not make AshUi or a host runtime part of the canonical contract.
  priority: should
  stability: stable
```

## Scenarios

```spec-scenarios
- id: unified_ui.widget_components.author_expanded_widget_screen
  covers:
    - unified_ui.widget_components.content_identity_and_disclosure_surface
    - unified_ui.widget_components.form_control_and_composer_surface
    - unified_ui.widget_components.row_and_artifact_surface
    - unified_ui.widget_components.workflow_progress_and_status_surface
    - unified_ui.widget_components.layer_shell_and_callout_surface
    - unified_ui.widget_components.redline_and_code_surface
  given:
    - A developer authors a document-workflow or operational screen using the expanded widget catalog
  when:
    - The developer composes rows, progress, redlines, code, callouts, forms, and composer controls in UnifiedUi
  then:
    - The authored module expresses the screen through canonical DSL constructs without calling runtime-library widgets directly

- id: unified_ui.widget_components.author_list_repeat
  covers:
    - unified_ui.widget_components.list_repeat_authoring
    - unified_ui.widget_components.portable_names_and_aliases
  given:
    - A developer wants to render one artifact-row child per row in a list binding
  when:
    - The developer attaches repeat composition behavior to the child template
  then:
    - UnifiedUi validates the list binding and row-scope bindings before emitting canonical IUR
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/unified-ui/widget_components.spec.md
  covers:
    - unified_ui.widget_components.content_identity_and_disclosure_surface
    - unified_ui.widget_components.form_control_and_composer_surface
    - unified_ui.widget_components.row_and_artifact_surface
    - unified_ui.widget_components.workflow_progress_and_status_surface
    - unified_ui.widget_components.layer_shell_and_callout_surface
    - unified_ui.widget_components.redline_and_code_surface
    - unified_ui.widget_components.list_repeat_authoring
    - unified_ui.widget_components.portable_names_and_aliases
    - unified_ui.widget_components.author_expanded_widget_screen
    - unified_ui.widget_components.author_list_repeat
```
