# Examples

This directory contains the standalone Phoenix LiveView example-application
suite for the unified ecosystem.

The suite is organized around one shared authoring template, one shared default
theme, one shared default style profile, and one dedicated standalone app per
primary widget or construct. Every example app is meant to be understandable on
its own while still proving the same authored-to-canonical-to-runtime path:
`UnifiedUi` DSL -> canonical `UnifiedIUR` -> `LiveUi` rendering.

If you want the fastest path to launching or validating the suite, start with
[Running the Examples](./running_the_examples.md).

`examples/demo/` is the aggregate category-oriented review surface. It uses the
same shared theme and style baseline as the current button example and gives
reviewers one browser-runnable shell for the ordered control categories.
Use it when you want an overview by control family; use the focused
`examples/<widget_name>/` apps when you want one widget's interaction story in
detail.

## Layout

- `shared/`: maintainer tooling, catalog, validation, and release-readiness
  helpers that remain useful for suite-wide review workflows
- one standalone app directory per implemented widget-focused example

Directory convention:

- every example app lives in `examples/<widget_name>/`
- every example app is a standalone Phoenix LiveView app and Mix project
- focused example apps are self-contained and do not depend on
  `examples/shared/`
- every focused example app depends on the local package paths for
  `unified_ui`, `unified_iur`, `live_ui`, `desktop_ui`, `elm_ui`, and
  `terminal_ui`
- every focused example app can be started from its own directory and defaults
  to `live_ui` when no target package is specified

## Shared Baseline

The shared authoring baseline gives every example app the same review surface:

- shared `UnifiedUi` DSL shell macros: `example_panel/1` and
  `example_form_panel/1`
- shared default theme id: `:example_suite_default`
- shared default style profile keys: `:shell`, `:panel`, `:form_shell`,
  `:title`, `:summary`, `:notes`, `:button`, and `:text_input`
- a common app-local launcher surface through `mix example.start`
- one meaningful authored interaction story per example so reviewers can
  understand what to try in the browser and what outcome to expect without
  opening source files

The point of the suite is not to let every app invent its own look and feel.
The point is to demonstrate one widget or construct at a time under one common
theme and style baseline so the rendered differences come from the widget
itself.

Every example app must now demonstrate a meaningful authored interaction.
Examples may use:

- source-driven interaction storytelling, where the showcased widget itself
  originates the primary interaction
- target-driven interaction storytelling, where a shared trigger or companion
  control updates the showcased passive or structural surface in a reviewer-
  visible way

## Cross-Package Traceability

Each example app is meant to be reviewable against the package contracts it is
demonstrating:

- `unified_ui` owns the authored DSL template and compiler surface
- `unified_iur` owns the canonical intermediate representation produced by that
  authored DSL
- `live_ui` is the default browser runtime target for the example suite
- `desktop_ui` is the native desktop target currently wired into the app-local
  launcher surface
- `elm_ui` is available through the same launcher as a review-oriented runtime
  snapshot of the Phoenix-and-Elm server/frontend path
- `terminal_ui` is available through the same launcher as a review-oriented
  runtime snapshot of the terminal runtime path

The shared support library exposes traceability metadata for every app so
reviewers can see the exact package roots, package specs, general ecosystem
specs, and governance contracts that define the example’s expected behavior.

## Maintainer Commands

Run these from `examples/shared/`:

- `mix examples.list`: print the current suite catalog
- `mix examples.launch <directory> --dry-run`: print the standalone Phoenix
  launch command or runtime-review command for one app
- `mix examples.launch <directory> --smoke-test`: boot one app through its
  Phoenix endpoint and verify the LiveView entrypoint responds for browser-
  runnable launch targets
- `mix examples.preview <directory>`: inspect one app through the shared
  preview path
- `mix examples.run <directory>`: run one app through its own test workflow
- `mix examples.validate --strict`: validate the current catalog, metadata, and
  shared-template continuity
- `mix examples.report`: print the cross-family review summary
- `mix examples.release --strict`: run the full documentation, traceability,
  validation, and release-readiness workflow
- `mix example.start`: run from any example app directory to launch that app,
  defaulting to `live_ui` and accepting `--target-package desktop_ui`,
  `--target-package elm_ui`, and `--target-package terminal_ui`
- `mix phx.server`: still works directly from example app directories for the
  default `live_ui` browser path

Direct browser workflow for any example app:

```bash
cd examples/button
mix deps.get
mix example.start
```

The default mount URL is `http://127.0.0.1:5000/`, and you can override the
port with `mix example.start --port 4100`.

Native desktop workflow for any focused example app:

```bash
cd examples/button
mix deps.get
mix example.start --target-package desktop_ui
```

ElmUi review workflow for any focused example app:

```bash
cd examples/button
mix deps.get
mix example.start --target-package elm_ui
```

This prints an `ElmUi` runtime snapshot to stdout for the compiled canonical
example instead of launching the LiveView browser shell.

TerminalUi review workflow for any focused example app:

```bash
cd examples/button
mix deps.get
mix example.start --target-package terminal_ui
```

Use `--backend-mode tty` when you want the fallback terminal-capability path:

```bash
cd examples/button
mix example.start --target-package terminal_ui --backend-mode tty
```

This prints a `TerminalUi` runtime snapshot to stdout for the compiled
canonical example instead of launching a browser or SDL window.

Aggregate demo workflow:

```bash
cd examples/demo
mix deps.get
mix example.start
```

Or preview the demo launch contract from the shared tooling:

```bash
cd examples/shared
mix examples.launch demo --dry-run
```

You can also preview non-browser launch commands from the shared tooling:

```bash
cd examples/shared
mix examples.launch button --runtime elm_ui --dry-run
mix examples.launch button --runtime terminal_ui --dry-run
```

When you launch an example, look for two shared review surfaces in the browser:

- `Meaningful Interaction Story`: explains what changed in human terms
- `Canonical Signal Preview`: shows the underlying canonical signal details

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

- [Example Apps Suite](../.spec/specs/examples/package.spec.md)
- [Example Apps Structure](../.spec/specs/examples/structure.spec.md)
- [Example Apps DSL Template](../.spec/specs/examples/dsl_template.spec.md)
- [Example Apps Catalog](../.spec/specs/examples/catalog.spec.md)
- [Example Apps Tooling](../.spec/specs/examples/tooling.spec.md)

Implementation plan:

- [Example Apps Planning Index](../.spec/planning/examples/README.md)
