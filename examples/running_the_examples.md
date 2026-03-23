# Running the Examples

This guide is the quickest way to launch and validate the standalone example
apps in [examples](./).

The example suite is made up of standalone Phoenix LiveView apps backed by the
shared helpers in [examples/shared](./shared).
Use this guide when you want to run one example app directly, launch the
aggregate demo, or use the shared maintainer tooling.

## Quick Start

Run one example app directly:

```bash
cd examples/button
mix deps.get
mix phx.server
```

Then open `http://127.0.0.1:4000/`.

Run the aggregate demo app:

```bash
cd examples/demo
mix deps.get
mix phx.server
```

This is the best entrypoint when you want one browser shell that groups the
examples by control family.

## Shared Tooling

Most maintainer workflows run from [examples/shared](./shared):

```bash
cd examples/shared
mix deps.get
```

List the current example catalog:

```bash
mix examples.list
```

Print the launch command for one example without starting it:

```bash
mix examples.launch button --dry-run
```

Boot one example and verify its LiveView entrypoint responds:

```bash
mix examples.launch button --smoke-test
```

Preview one example through the shared inspection path:

```bash
mix examples.preview button
```

Run one example through its own test workflow:

```bash
mix examples.run button
```

Validate the full suite catalog and shared template continuity:

```bash
mix examples.validate --strict
```

Print the suite report:

```bash
mix examples.report
```

Run the full release-readiness workflow:

```bash
mix examples.release --strict
```

## Choosing an Example

The full catalog is documented in
[examples/README.md](./README.md),
but these are common starting points:

- `examples/demo`: aggregate review surface
- `examples/button`: simplest interaction-focused app
- `examples/form_builder`: authored form flow
- `examples/table`: data-display review path
- `examples/dialog`: overlay and layered flow
- `examples/cluster_dashboard`: advanced operational surface
- `examples/viewport`: display-system behavior
- `examples/canvas`: rendering and display construct behavior

## Ports and URLs

By default, Phoenix serves an example app at `http://127.0.0.1:4000/`.

To use a different port:

```bash
cd examples/button
mix deps.get
PORT=4100 mix phx.server
```

## What to Look For

When an example is running in the browser, the shared template should expose:

- `Meaningful Interaction Story`
- `Canonical Signal Preview`

Those two surfaces make it easier to review the authored interaction in human
terms and the canonical signal behavior side by side.

## Related References

- [Examples README](./README.md)
- [Example Apps Suite Spec](../.spec/specs/examples/package.spec.md)
- [Example Apps Planning Index](../.spec/planning/examples/README.md)
