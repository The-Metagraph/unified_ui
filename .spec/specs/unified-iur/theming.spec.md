# Unified IUR Theming

This subject defines the canonical style and theme structures that `unified_iur` shall represent.

## Related General Specs

- [Architecture](../architecture.spec.md)
- [DSL and IUR Symbiosis](../dsl_iur_symbiosis.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)

```spec-meta
id: unified_iur.theming
kind: capability
status: proposed
summary: Canonical style and theme structures representable in `unified_iur`.
surface:
  - packages/unified_iur
  - .spec/specs/unified-iur/theming.spec.md
  - .spec/specs/unified-ui/theming.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: unified_iur.theming.theme_structure
  statement: `unified_iur` shall represent theme definitions with a theme identity, base color palette, semantic color roles, and per-component style variants.
  priority: must
  stability: stable

- id: unified_iur.theming.color_model
  statement: `unified_iur` shall represent named colors, indexed colors, and RGB colors for canonical styling definitions.
  priority: must
  stability: stable

- id: unified_iur.theming.text_style_attributes
  statement: `unified_iur` shall represent text and emphasis attributes including bold, dim, italic, underline, blink, reverse, hidden, and strikethrough.
  priority: must
  stability: stable

- id: unified_iur.theming.semantic_roles
  statement: `unified_iur` shall represent semantic style roles including success, warning, error, info, muted, help, and placeholder.
  priority: must
  stability: stable

- id: unified_iur.theming.component_variants
  statement: `unified_iur` shall represent component style variants and state-scoped styling for cases such as normal, focused, disabled, selected, and emphasis-oriented rendering states.
  priority: must
  stability: stable

- id: unified_iur.theming.inheritance_and_overrides
  statement: `unified_iur` shall represent theme-level defaults together with local style inheritance, merging, and override behavior so renderers can reconstruct effective widget styling.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/unified-iur/theming.spec.md
  covers:
    - unified_iur.theming.theme_structure
    - unified_iur.theming.color_model
    - unified_iur.theming.text_style_attributes
    - unified_iur.theming.semantic_roles
    - unified_iur.theming.component_variants
    - unified_iur.theming.inheritance_and_overrides
```
