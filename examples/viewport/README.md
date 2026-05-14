# Unified Examples Viewport

This standalone Phoenix LiveView app demonstrates the `viewport` widget through the shared example-suite DSL template, theme, and style profile.

It uses target-driven interaction storytelling so reviewers can understand both the browser-visible outcome and the canonical signal meaning.

## Run

From this directory:

`mix deps.get`
`mix phx.server`

The app mounts at `http://127.0.0.1:5000/` by default. Override the port with
`PORT=5100 mix phx.server`.

## Try It

Use the shared trigger to see how the viewport example explains focus changes in movement, focus, or rendering context.

If the example uses the shared trigger, click `Inspect the viewport display story`.

## Expect

The review panel should explain how the viewport example turns an authored canonical interaction into a browser-visible display-system story.

The browser should keep both the `Meaningful Interaction Story` panel and the
`Canonical Signal Preview` panel visible while you review the example.

## Validate

`mix test`
