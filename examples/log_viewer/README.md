# Unified Examples Log viewer

This standalone Phoenix LiveView app demonstrates the `log_viewer` widget through the shared example-suite DSL template, theme, and style profile.

It uses target-driven interaction storytelling so reviewers can understand both the browser-visible outcome and the canonical signal meaning.

## Run

From this directory:

`mix deps.get`
`mix phx.server`

The app mounts at `http://127.0.0.1:5000/` by default. Override the port with
`PORT=5100 mix phx.server`.

## Try It

Use the shared trigger to see how the log viewer example explains focus changes such as focus, filtering, or selection.

If the example uses the shared trigger, click `Inspect the log viewer data story`.

## Expect

The review panel should explain how the log viewer example turns an authored canonical interaction into a browser-visible data story reviewers can understand quickly.

The browser should keep both the `Meaningful Interaction Story` panel and the
`Canonical Signal Preview` panel visible while you review the example.

## Validate

`mix test`
