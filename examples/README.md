# Examples

This directory contains the standalone Phoenix LiveView example-application
suite for the unified ecosystem.

The suite is organized around one shared authoring template, one shared default
theme, one shared default style profile, and one dedicated standalone app per
primary widget or construct. Every example app is meant to be understandable on
its own while still proving the same authored-to-canonical-to-runtime path:
`UnifiedUi` DSL -> canonical `UnifiedIUR` -> `LiveUi` rendering.

## Layout

- `shared/`: the shared support library that owns the common dependency wiring,
  DSL template, catalog, runtime helpers, release checks, and maintainer tasks
- one standalone app directory per implemented widget-focused example

Directory convention:

- every example app lives in `examples/<widget_name>/`
- every example app is a standalone Phoenix LiveView app and Mix project
- every example app depends on `examples/shared/` plus the local package paths
  for `unified_ui`, `unified_iur`, and `live_ui`
- every example app reuses the shared template in
  `UnifiedExamples.Shared.Template`

## Shared Baseline

The shared authoring template gives every example app the same review surface:

- shared `UnifiedUi` DSL shell macros: `example_panel/1` and
  `example_form_panel/1`
- shared default theme id: `:example_suite_default`
- shared default style profile keys: `:shell`, `:panel`, `:form_shell`,
  `:title`, `:summary`, `:notes`, `:button`, and `:text_input`
- shared runtime flow through `examples/shared/` helpers rather than
  app-specific boot code

The point of the suite is not to let every app invent its own look and feel.
The point is to demonstrate one widget or construct at a time under one common
theme and style baseline so the rendered differences come from the widget
itself.

## Cross-Package Traceability

Each example app is meant to be reviewable against the package contracts it is
demonstrating:

- `unified_ui` owns the authored DSL template and compiler surface
- `unified_iur` owns the canonical intermediate representation produced by that
  authored DSL
- `live_ui` owns the runtime rendering path that mounts the resulting canonical
  screen under the shared theme and style baseline

The shared support library exposes traceability metadata for every app so
reviewers can see the exact package roots, package specs, general ecosystem
specs, and governance contracts that define the example’s expected behavior.

## Maintainer Commands

Run these from `examples/shared/`:

- `mix examples.list`: print the current suite catalog
- `mix examples.launch <directory> --dry-run`: print the standalone Phoenix
  launch command for one app
- `mix examples.launch <directory> --smoke-test`: boot one app through its
  Phoenix endpoint and verify the LiveView entrypoint responds
- `mix examples.preview <directory>`: inspect one app through the shared
  preview path
- `mix examples.run <directory>`: run one app through its own test workflow
- `mix examples.validate --strict`: validate the current catalog, metadata, and
  shared-template continuity
- `mix examples.report`: print the cross-family review summary
- `mix examples.release --strict`: run the full documentation, traceability,
  validation, and release-readiness workflow
- `mix phx.server`: run from any `examples/<widget_name>/` directory to launch
  that example directly in the browser

Direct browser workflow for any example app:

```bash
cd /Users/Pascal/code/unified/examples/button
mix deps.get
mix phx.server
```

The default mount URL is `http://127.0.0.1:4000/`, and you can override the
port with `PORT=4100 mix phx.server`.

## Catalog

Currently implemented apps:

- Foundational content and layout:
  `text/`, `button/`, `label/`, `icon/`, `image/`, `link/`, `separator/`,
  `spacer/`, `content/`, `box/`
- Forms and input scaffolding:
  `form_builder/`, `field_group/`, `field/`
- Input controls:
  `text_input/`, `numeric_input/`, `checkbox/`, `radio_group/`, `select/`,
  `pick_list/`, `date_input/`, `time_input/`, `file_input/`, `toggle/`
- Layout and navigation:
  `row/`, `column/`, `grid/`, `menu/`, `tabs/`, `command_palette/`
- Display systems:
  `viewport/`, `scroll_bar/`, `split_pane/`, `canvas/`
- Overlays and layered flows:
  `overlay/`, `dialog/`, `alert_dialog/`, `context_menu/`, `toast/`
- Operational and monitoring:
  `stream_widget/`, `process_monitor/`, `supervision_tree_viewer/`,
  `cluster_dashboard/`
- Baseline data views:
  `list/`, `table/`, `tree_view/`, `markdown_viewer/`, `log_viewer/`
- Feedback and charts:
  `status/`, `progress/`, `gauge/`, `inline_feedback/`, `sparkline/`,
  `bar_chart/`, `line_chart/`

Discovery surfaces:

- `examples/catalog.tsv` is the machine-readable catalog manifest for the suite
- `examples/shared/` exposes the shared catalog, fixtures, runtime helpers,
  documentation checks, traceability metadata, and release-readiness workflow
- the family groupings above are the human-readable landing page for the same
  catalog entries

Authoritative suite contract:

- [Example Apps Suite](/Users/Pascal/code/unified/.spec/specs/examples/package.spec.md)
- [Example Apps Structure](/Users/Pascal/code/unified/.spec/specs/examples/structure.spec.md)
- [Example Apps DSL Template](/Users/Pascal/code/unified/.spec/specs/examples/dsl_template.spec.md)
- [Example Apps Catalog](/Users/Pascal/code/unified/.spec/specs/examples/catalog.spec.md)
- [Example Apps Tooling](/Users/Pascal/code/unified/.spec/specs/examples/tooling.spec.md)

Implementation plan:

- [Example Apps Planning Index](/Users/Pascal/code/unified/.spec/planning/examples/README.md)
