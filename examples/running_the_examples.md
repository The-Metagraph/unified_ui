# Running the Examples

This guide is the quickest way to launch and validate the standalone example
apps in [examples](./).

The suite is made up of focused, self-contained example apps that can be
started from their own directories.

## Quick Start

Run one example app directly:

```bash
cd examples/button
mix deps.get
mix example.start
```

Then open `http://127.0.0.1:5000/`.

Run one focused example app with a different target package:

```bash
mix example.start --target-package desktop_ui
mix example.start --target-package elm_ui
mix example.start --target-package terminal_ui
```

Use `--backend-mode tty` when you want the fallback terminal backend:

```bash
mix example.start --target-package terminal_ui --backend-mode tty
```

The `elm_ui` and `terminal_ui` review paths emit runtime output to stdout
instead of exposing a Phoenix URL.

## Ports and URLs

By default, Phoenix serves an example app at `http://127.0.0.1:5000/`.

To use a different port:

```bash
mix example.start --port 4100
```

## Validation

Run validation from the focused example directory:

```bash
mix test
```

## Choosing an Example

The full catalog is documented in [examples/README.md](./README.md), and the
machine-readable manifest is [catalog.tsv](./catalog.tsv). Common starting
points:

- `examples/button`: simplest interaction-focused app
- `examples/form_builder`: authored form flow
- `examples/table`: data-display review path
- `examples/dialog`: overlay and layered flow
- `examples/cluster_dashboard`: advanced operational surface
- `examples/viewport`: display-system behavior
- `examples/canvas`: rendering and display construct behavior

## What to Look For

When an example is running in the browser, the common template should expose:

- `Meaningful Interaction Story`
- `Canonical Signal Preview`

Those two surfaces make it easier to review the authored interaction in human
terms and the canonical signal behavior side by side.

## Related References

- [Examples README](./README.md)
- [Example Apps Suite Spec](../.spec/specs/examples/package.spec.md)
- [Example Apps Planning Index](../.spec/planning/examples/README.md)
