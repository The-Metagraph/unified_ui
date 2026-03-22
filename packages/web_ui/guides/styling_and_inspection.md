# Styling And Inspection

`web_ui` keeps theme meaning and style resolution server-authoritative while
still producing deterministic browser-facing realization.

## Styling Surface

- `WebUi.Style`
  - style primitives
  - widget style hooks
  - state variants
- `WebUi.Theme`
  - theme catalogs
  - token resolution
  - continuity rules

## Cross-Runtime Styling

- `WebUi.ServerRuntime.StyleResolver` computes resolved style meaning.
- `WebUi.FrontendRuntime.StyleRealization` computes browser-facing class,
  variable, transition, and responsive payloads.

## Inspection And Continuity

- `WebUi.Inspection.runtime_snapshot/2` exposes server and frontend style state.
- `WebUi.Continuity.compare/3` compares native and canonical runtime behavior.
- `WebUi.Examples.styling_comparison/0` provides a maintained styling-heavy
  review artifact.

Use these when reviewing:

- unresolved theme tokens
- invalid state-variant wiring
- incompatible style combinations
- theme propagation drift
- frontend realization drift
