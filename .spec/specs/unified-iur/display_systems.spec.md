# Unified IUR Display Systems

This subject defines the canonical layout, layering, viewport, and canvas structures that `unified_iur` shall represent.

## Related General Specs

- [Architecture](../architecture.spec.md)
- [DSL and IUR Symbiosis](../dsl_iur_symbiosis.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)

```spec-meta
id: unified_iur.display_systems
kind: capability
status: proposed
summary: Canonical layout, layer, viewport, and canvas structures representable in `unified_iur`.
surface:
  - packages/unified_iur
  - .spec/specs/unified-iur/display_systems.spec.md
  - .spec/specs/unified-ui/display_systems.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: unified_iur.display_systems.layout_primitives
  statement: `unified_iur` shall represent box-style containers, vertical stacks, horizontal stacks, split panes, viewport regions, and alignment or constraint metadata as canonical display structures.
  priority: must
  stability: stable

- id: unified_iur.display_systems.layering_primitives
  statement: `unified_iur` shall represent overlays, absolute positioned content, background-filled overlay regions, and composite overlay-driven views such as dialogs, menus, and toasts.
  priority: must
  stability: stable

- id: unified_iur.display_systems.viewport_and_clipping
  statement: `unified_iur` shall represent bounded viewport regions with clipping behavior, dimensions, and scroll offsets as first-class display structures.
  priority: must
  stability: stable

- id: unified_iur.display_systems.canvas_surface
  statement: `unified_iur` shall represent a canvas-style drawing surface and positioned cell or fragment placement for direct visual composition beyond standard widget layout.
  priority: must
  stability: stable

- id: unified_iur.display_systems.compose_with_widgets
  statement: Canonical `unified_iur` layout, layer, viewport, and canvas structures shall compose with canonical widgets as one unified interchange model rather than as detached subsystems.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/unified-iur/display_systems.spec.md
  covers:
    - unified_iur.display_systems.layout_primitives
    - unified_iur.display_systems.layering_primitives
    - unified_iur.display_systems.viewport_and_clipping
    - unified_iur.display_systems.canvas_surface
    - unified_iur.display_systems.compose_with_widgets
```
