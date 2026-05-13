# UnifiedIUR Constructs

This subject defines the canonical construct families that `unified_iur` must
represent for authored DSL and runtime-library parity.

## Related General Specs

- [DSL and IUR Symbiosis](../dsl_iur_symbiosis.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [UnifiedIUR Package](./package.spec.md)
- [UnifiedIUR Core](./core.spec.md)

```spec-meta
id: unified_iur.constructs
kind: subsystem
status: active
summary: Target canonical construct surface for widgets, layouts, layering, styling, and theming in `unified_iur`.
surface:
  - packages/unified_iur
  - .spec/specs/unified-iur/constructs.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.widget_portability_from_ash_ui
```

## Requirements

```spec-requirements
- id: unified_iur.constructs.foundational_widgets
  statement: The package shall represent foundational visual and content constructs such as text, labels, icons, images, buttons, links, separators, spacers, and basic content containers as canonical IUR elements.
  priority: must
  stability: stable

- id: unified_iur.constructs.input_and_form_widgets
  statement: The package shall represent canonical form and input constructs including text entry, numeric entry, toggles, selections, pick lists, sliders, date or time input, file-oriented input, and form composition primitives.
  priority: must
  stability: stable

- id: unified_iur.constructs.layout_and_layering
  statement: The package shall represent canonical container, row, column, grid, stack, split, scroll, viewport, overlay, modal, and z-order layering constructs needed to describe authored UI hierarchy and visual composition.
  priority: must
  stability: stable

- id: unified_iur.constructs.navigation_feedback_and_data
  statement: The package shall represent canonical navigation, feedback, and data-display constructs including menus, tabs, dialogs, toast or alert feedback, lists, tables, trees, progress or status widgets, and chart-like or inspection-oriented widgets.
  priority: must
  stability: stable

- id: unified_iur.constructs.styling_attributes
  statement: The package shall represent canonical styling attributes for typography, spacing, sizing, alignment, colors, borders, backgrounds, visibility, emphasis, and state variants needed for renderer-library parity.
  priority: must
  stability: stable

- id: unified_iur.constructs.theme_and_token_representation
  statement: The package shall represent theme-level configuration and reusable design-token references so canonical styling and theming constructs survive compilation into IUR.
  priority: must
  stability: stable

- id: unified_iur.constructs.canonical_surface_for_runtime_parity
  statement: The package shall define the canonical construct surface that runtime libraries are expected to cover fully with their own native widget, layer, and styling models.
  priority: must
  stability: stable

- id: unified_iur.constructs.repeated_collection_composition
  statement: The package shall represent repeated collection composition as a renderer-independent relationship between a list-oriented binding, a child widget or layout template, row-scope value access, and stable generated child identity expectations.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: unified_iur.constructs.capture_full_screen_structure
  covers:
    - unified_iur.constructs.foundational_widgets
    - unified_iur.constructs.input_and_form_widgets
    - unified_iur.constructs.layout_and_layering
    - unified_iur.constructs.navigation_feedback_and_data
    - unified_iur.constructs.styling_attributes
    - unified_iur.constructs.theme_and_token_representation
    - unified_iur.constructs.canonical_surface_for_runtime_parity
    - unified_iur.constructs.repeated_collection_composition
  given:
    - An authored UI contains layered navigation, forms, feedback widgets, styled content, and data-heavy sections
  when:
    - The authored module compiles into IUR
  then:
    - The resulting canonical structures can represent the full screen without collapsing unsupported constructs into runtime-specific escape hatches
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/unified-iur/constructs.spec.md
  covers:
    - unified_iur.constructs.foundational_widgets
    - unified_iur.constructs.input_and_form_widgets
    - unified_iur.constructs.layout_and_layering
    - unified_iur.constructs.navigation_feedback_and_data
    - unified_iur.constructs.styling_attributes
    - unified_iur.constructs.theme_and_token_representation
    - unified_iur.constructs.canonical_surface_for_runtime_parity
    - unified_iur.constructs.repeated_collection_composition
```
