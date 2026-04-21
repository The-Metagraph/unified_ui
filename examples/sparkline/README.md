# Unified Examples Sparkline

This standalone Phoenix LiveView app demonstrates the `sparkline` widget through the shared example-suite DSL template, theme, and style profile.

It uses target-driven interaction storytelling so reviewers can understand both the browser-visible outcome and the canonical signal meaning.

## Run

From this directory:

`mix deps.get`
`mix phx.server`

The app mounts at `http://127.0.0.1:5000/` by default. Override the port with
`PORT=5100 mix phx.server`.

## Try It

Use the shared trigger to see how the sparkline example explains click changes in metric or feedback meaning.

If the example uses the shared trigger, click `Inspect the sparkline feedback story`.

## Expect

The review panel should explain how the sparkline example turns an authored canonical interaction into a browser-visible feedback story.

The browser should keep both the `Meaningful Interaction Story` panel and the
`Canonical Signal Preview` panel visible while you review the example.

## Aggregate Demo

Review this widget from the aggregate overview in `examples/demo/`.

This example appears in the aggregate demo categories:
Data and Feedback

## Validate

`mix test`

Shared suite support lives in `../shared`.
