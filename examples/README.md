# Examples

This directory contains standalone example apps for the unified ecosystem.

Each app demonstrates one primary widget or construct through the shared
authoring path:

`UnifiedUi` DSL -> canonical `UnifiedIUR` -> runtime rendering.

Every example app is self-contained. There is no shared example support package
and no aggregate demo application; use `examples/catalog.tsv` to discover the
available focused examples.

## Layout

- `catalog.tsv`: machine-readable catalog manifest for the suite
- `<widget_name>/`: one standalone Mix project per focused example

Directory convention:

- every example app lives in `examples/<widget_name>/`
- every example app is a standalone Phoenix LiveView app and Mix project
- every example app owns its authored modules, runtime entrypoints, theme
  definitions, and example-shell helpers locally
- every example app depends on the local package paths for `unified_ui`,
  `unified_iur`, `live_ui`, `desktop_ui`, `elm_ui`, and `terminal_ui`
- every example app can be started from its own directory and defaults to
  `live_ui` when no target package is specified

## Runtime Workflow

Run one browser example:

```bash
cd examples/button
mix deps.get
mix example.start
```

The default URL is `http://127.0.0.1:5000/`. Override it with
`mix example.start --port 4100`.

Run the same focused example through another maintained target:

```bash
mix example.start --target-package desktop_ui
mix example.start --target-package elm_ui
mix example.start --target-package terminal_ui
```

Use `--backend-mode tty` with the terminal target when you want the fallback
terminal-capability path:

```bash
mix example.start --target-package terminal_ui --backend-mode tty
```

Run an example's local tests:

```bash
mix test
```

## Review Surface

Every example app should preserve the suite default theme and style profile
while foregrounding one primary widget or construct. Each app should also
include one meaningful authored interaction so reviewers can compare the human
behavior and canonical signal meaning.

Browser examples expose the common review areas:

- `Meaningful Interaction Story`
- `Canonical Signal Preview`

The `elm_ui` and `terminal_ui` review paths emit structured runtime output to
stdout instead of launching the LiveView browser shell.

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

Authoritative suite contract:

- [Example Apps Suite](../.spec/specs/examples/package.spec.md)
- [Example Apps Structure](../.spec/specs/examples/structure.spec.md)
- [Example Apps DSL Template](../.spec/specs/examples/dsl_template.spec.md)
- [Example Apps Catalog](../.spec/specs/examples/catalog.spec.md)
- [Example Apps Tooling](../.spec/specs/examples/tooling.spec.md)

Useful guide:

- [Running the Examples](./running_the_examples.md)
