# Examples

This directory contains the standalone example-application suite for the
unified ecosystem.

Current layout:

- `shared/`: the shared support library that owns the common dependency wiring,
  DSL template, and suite-wide theme/style defaults
- `text/`, `button/`, `text_input/`: the first widget-focused app directories
  that will be populated during Phase 1

Directory convention:

- every example app lives in `examples/<widget_name>/`
- every example app is a standalone Mix project
- every example app depends on `examples/shared/` plus the local package paths
  for `unified_ui`, `unified_iur`, and `live_ui`

Authoritative suite contract:

- [Example Apps Suite](/Users/Pascal/code/unified/.spec/specs/examples/package.spec.md)
- [Example Apps Structure](/Users/Pascal/code/unified/.spec/specs/examples/structure.spec.md)
- [Example Apps DSL Template](/Users/Pascal/code/unified/.spec/specs/examples/dsl_template.spec.md)
- [Example Apps Catalog](/Users/Pascal/code/unified/.spec/specs/examples/catalog.spec.md)
- [Example Apps Tooling](/Users/Pascal/code/unified/.spec/specs/examples/tooling.spec.md)

Implementation plan:

- [Example Apps Planning Index](/Users/Pascal/code/unified/.spec/planning/examples/README.md)
