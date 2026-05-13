# DSL and IUR Symbiosis

This subject defines the bilateral contract between the `unified_ui` DSL and the canonical `unified_iur` data model.

```spec-meta
id: ecosystem.dsl_iur_symbiosis
kind: integration
status: active
summary: Symbiotic contract between authored DSL entities in `unified_ui` and canonical widget, layout, layering, styling, and theming representation in `unified_iur`.
surface:
  - packages/unified-ui
  - packages/unified_iur
  - .spec/specs/dsl_iur_symbiosis.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.widget_portability_from_ash_ui
```

## Requirements

```spec-requirements
- id: ecosystem.dsl_iur_symbiosis.dsl_entities_have_iur_representation
  statement: Every DSL entity and attribute intended for canonical rendering shall have a representation in `unified_iur`.
  priority: must
  stability: stable

- id: ecosystem.dsl_iur_symbiosis.canonical_iur_constructs_representable_in_dsl
  statement: Every canonical `unified_iur` widget, layout, layering, styling, and theming construct intended for ecosystem-wide authoring shall be representable through the `unified_ui` DSL.
  priority: must
  stability: stable

- id: ecosystem.dsl_iur_symbiosis.iur_covers_widget_layout_layer_theme
  statement: `unified_iur` shall be able to represent widgets, layouts, layering, styling attributes, and theming constructs required by `unified_ui`.
  priority: must
  stability: stable

- id: ecosystem.dsl_iur_symbiosis.layering_and_theming_stay_in_dsl
  statement: Layering and theming shall remain part of the canonical `unified_ui` DSL surface and shall not be treated as separate authoring systems outside the DSL and IUR symbiosis.
  priority: must
  stability: stable

- id: ecosystem.dsl_iur_symbiosis.dsl_compiles_to_iur
  statement: `unified_ui` shall compile authored DSL constructs into canonical `unified_iur` data rather than renderer-specific output formats.
  priority: must
  stability: stable

- id: ecosystem.dsl_iur_symbiosis.bilateral_change_rule
  statement: Introducing or changing canonical DSL surface that affects rendering semantics shall be accompanied by the corresponding `unified_iur` representation change, and vice versa when the IUR addition is intended for canonical DSL authoring.
  priority: must
  stability: stable

- id: ecosystem.dsl_iur_symbiosis.consumer_originated_widget_promotion
  statement: Generally useful widget or composition concepts first introduced by integration packages such as AshUi shall move into both the canonical `unified_ui` authored surface and the canonical `unified_iur` representation when they are intended for ecosystem-wide rendering.
  priority: must
  stability: stable
```

## Exceptions

```spec-exceptions
- id: ecosystem.dsl_iur_symbiosis.coverage_evolving
  covers:
    - ecosystem.dsl_iur_symbiosis.dsl_entities_have_iur_representation
    - ecosystem.dsl_iur_symbiosis.canonical_iur_constructs_representable_in_dsl
    - ecosystem.dsl_iur_symbiosis.iur_covers_widget_layout_layer_theme
    - ecosystem.dsl_iur_symbiosis.layering_and_theming_stay_in_dsl
  reason: The architecture requires full DSL and IUR symmetry, but widget, layering, and theming coverage is still expanding across the ecosystem.
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/dsl_iur_symbiosis.spec.md
  covers:
    - ecosystem.dsl_iur_symbiosis.dsl_entities_have_iur_representation
    - ecosystem.dsl_iur_symbiosis.canonical_iur_constructs_representable_in_dsl
    - ecosystem.dsl_iur_symbiosis.iur_covers_widget_layout_layer_theme
    - ecosystem.dsl_iur_symbiosis.layering_and_theming_stay_in_dsl
    - ecosystem.dsl_iur_symbiosis.dsl_compiles_to_iur
    - ecosystem.dsl_iur_symbiosis.bilateral_change_rule
    - ecosystem.dsl_iur_symbiosis.consumer_originated_widget_promotion
```
