# Unified UI Theming

This subject defines the canonical styling and theming surface that the `unified_ui` DSL shall expose.

## Related General Specs

- [Architecture](../architecture.spec.md)
- [DSL and IUR Symbiosis](../dsl_iur_symbiosis.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)

```spec-meta
id: unified_ui.theming
kind: capability
status: proposed
summary: Canonical style and theme authoring surface for `unified_ui`.
surface:
  - packages/unified-ui
  - .spec/specs/unified-ui/theming.spec.md
  - .spec/specs/unified-iur/theming.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: unified_ui.theming.theme_structure
  statement: The canonical `unified_ui` DSL shall support theme definitions with a theme identity, base color palette, semantic color roles, and per-component style variants.
  priority: must
  stability: stable

- id: unified_ui.theming.color_model
  statement: The canonical `unified_ui` DSL shall support named colors, indexed colors, and RGB colors for canonical styling definitions.
  priority: must
  stability: stable

- id: unified_ui.theming.text_style_attributes
  statement: The canonical `unified_ui` DSL shall support text and emphasis attributes including bold, dim, italic, underline, blink, reverse, hidden, and strikethrough.
  priority: must
  stability: stable

- id: unified_ui.theming.semantic_roles
  statement: The canonical `unified_ui` DSL shall support semantic style roles including success, warning, error, info, muted, help, and placeholder.
  priority: must
  stability: stable

- id: unified_ui.theming.component_variants
  statement: The canonical `unified_ui` DSL shall support component style variants and state-scoped styling for cases such as normal, focused, disabled, selected, and emphasis-oriented rendering states.
  priority: must
  stability: stable

- id: unified_ui.theming.inheritance_and_overrides
  statement: The canonical `unified_ui` DSL shall support theme-level defaults together with local style inheritance, merging, and override behavior so authored widgets can refine shared theme values.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/unified-ui/theming.spec.md
  covers:
    - unified_ui.theming.theme_structure
    - unified_ui.theming.color_model
    - unified_ui.theming.text_style_attributes
    - unified_ui.theming.semantic_roles
    - unified_ui.theming.component_variants
    - unified_ui.theming.inheritance_and_overrides
```
