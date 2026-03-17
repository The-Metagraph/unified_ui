# Unified Examples Overlay

This standalone Phoenix LiveView app demonstrates the `overlay` widget through the shared example-suite DSL template, theme, and style profile.

It uses target-driven interaction storytelling so reviewers can understand both the browser-visible outcome and the canonical signal meaning.

## Run

From this directory:

`mix deps.get`
`mix phx.server`

The app mounts at `http://127.0.0.1:4000/` by default. Override the port with
`PORT=4100 mix phx.server`.

## Try It

Use the shared trigger to see how the overlay example explains open changes in layered or contextual UI.

If the example uses the shared trigger, click `Inspect the overlay layered story`.

## Expect

The review panel should explain how the overlay example turns an authored canonical interaction into a browser-visible overlay story.

The browser should keep both the `Meaningful Interaction Story` panel and the
`Canonical Signal Preview` panel visible while you review the example.

## Aggregate Demo

Review this widget from the aggregate overview in `examples/demo/`.

This example appears in the aggregate demo categories:
Overlays and Operational

## Validate

`mix test`

Shared suite support lives in `../shared`.
