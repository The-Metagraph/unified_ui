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
  - repo.ecosystem.css_style_authoring
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

- id: unified_ui.theming.css_block_style_authoring
  statement: The canonical `unified_ui` DSL shall support CSS stylesheet blocks as a style-authoring convenience that translates supported CSS declarations into canonical style values, theme component styles, and state-scoped variants.
  priority: must
  stability: stable

- id: unified_ui.theming.css_selector_matching
  statement: CSS stylesheet rules shall match authored nodes only through supported canonical selectors such as stable ids, portable classes, widget or component kinds, explicitly supported structural selectors, and supported state pseudo-classes.
  priority: must
  stability: stable

- id: unified_ui.theming.css_cascade_precedence
  statement: CSS-derived style resolution shall honor specificity and source order for supported rules, then merge with existing theme and style precedence so explicit local style declarations outrank CSS-derived values.
  priority: must
  stability: stable

- id: unified_ui.theming.css_authoring_caveat
  statement: Accepting CSS stylesheet text shall not imply full browser CSS semantic equivalence; unsupported selectors, at-rules, properties, values, units, functions, and unsafe external-resource features shall be ignored with diagnostics instead of being emitted as raw runtime CSS.
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
    - unified_ui.theming.css_block_style_authoring
    - unified_ui.theming.css_selector_matching
    - unified_ui.theming.css_cascade_precedence
    - unified_ui.theming.css_authoring_caveat
```
