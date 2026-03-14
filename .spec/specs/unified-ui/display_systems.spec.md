# Unified UI Display Systems

This subject defines the canonical layout, layering, viewport, and canvas authoring systems that the `unified_ui` DSL shall provide.

## Related General Specs

- [Architecture](../architecture.spec.md)
- [DSL and IUR Symbiosis](../dsl_iur_symbiosis.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)

```spec-meta
id: unified_ui.display_systems
kind: capability
status: proposed
summary: Canonical layout, layer, viewport, and canvas authoring constructs for `unified_ui`.
surface:
  - packages/unified-ui
  - .spec/specs/unified-ui/display_systems.spec.md
  - .spec/specs/unified-iur/display_systems.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: unified_ui.display_systems.layout_primitives
  statement: The canonical `unified_ui` DSL shall provide layout constructs for box-style containers, vertical stacks, horizontal stacks, split panes, viewport regions, and explicit alignment or constraint metadata.
  priority: must
  stability: stable

- id: unified_ui.display_systems.layering_primitives
  statement: The canonical `unified_ui` DSL shall provide layering constructs for overlays, absolute positioned content, background-filled overlay regions, and composite overlay-driven views such as dialogs, menus, and toasts.
  priority: must
  stability: stable

- id: unified_ui.display_systems.viewport_and_clipping
  statement: The canonical `unified_ui` DSL shall support viewport-based display regions with bounded dimensions, clipping semantics, and scroll offsets as first-class display constructs.
  priority: must
  stability: stable

- id: unified_ui.display_systems.canvas_surface
  statement: The canonical `unified_ui` DSL shall support a canvas-style drawing surface and positioned cell or fragment placement for direct visual composition beyond standard widget layout.
  priority: must
  stability: stable

- id: unified_ui.display_systems.compose_with_widgets
  statement: The canonical layout, layer, viewport, and canvas systems shall compose with the canonical widget catalog rather than existing as separate authoring systems outside the DSL.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/unified-ui/display_systems.spec.md
  covers:
    - unified_ui.display_systems.layout_primitives
    - unified_ui.display_systems.layering_primitives
    - unified_ui.display_systems.viewport_and_clipping
    - unified_ui.display_systems.canvas_surface
    - unified_ui.display_systems.compose_with_widgets
```
