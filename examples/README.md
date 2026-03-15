# Examples

This directory contains the standalone example-application suite for the
unified ecosystem.

The suite is organized around one shared authoring template, one shared default
theme/style baseline, and one dedicated standalone app per primary widget or
construct.

Current layout:

- `shared/`: the shared support library that owns the common dependency wiring,
  DSL template, and suite-wide theme/style defaults
- one standalone app directory per implemented widget-focused example

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

Directory convention:

- every example app lives in `examples/<widget_name>/`
- every example app is a standalone Mix project
- every example app depends on `examples/shared/` plus the local package paths
  for `unified_ui`, `unified_iur`, and `live_ui`

Discovery surfaces:

- `examples/catalog.tsv` is the machine-readable catalog manifest for the suite
- `examples/shared/` is the shared support library that exposes the catalog,
  fixtures, runtime helpers, and suite-wide template contract
- the family groupings above are the human-readable landing page for the same
  catalog entries

Shared review surfaces:

- `examples/shared` exposes the implemented catalog and family grouping for the
  current example suite
- the shared catalog is expected to stay aligned with the implemented app
  directories as the suite grows

Authoritative suite contract:

- [Example Apps Suite](/Users/Pascal/code/unified/.spec/specs/examples/package.spec.md)
- [Example Apps Structure](/Users/Pascal/code/unified/.spec/specs/examples/structure.spec.md)
- [Example Apps DSL Template](/Users/Pascal/code/unified/.spec/specs/examples/dsl_template.spec.md)
- [Example Apps Catalog](/Users/Pascal/code/unified/.spec/specs/examples/catalog.spec.md)
- [Example Apps Tooling](/Users/Pascal/code/unified/.spec/specs/examples/tooling.spec.md)

Implementation plan:

- [Example Apps Planning Index](/Users/Pascal/code/unified/.spec/planning/examples/README.md)
