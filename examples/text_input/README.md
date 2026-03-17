# Unified Examples Text input

This standalone Phoenix LiveView app demonstrates the `text_input` widget through the shared example-suite DSL template, theme, and style profile.

It uses source-driven interaction storytelling so reviewers can understand both the browser-visible outcome and the canonical signal meaning.

## Run

From this directory:

`mix deps.get`
`mix phx.server`

The app mounts at `http://127.0.0.1:4000/` by default. Override the port with
`PORT=4100 mix phx.server`.

## Try It

Type into the draft field to capture the authored change signal and latest value.



## Expect

The text input example should mirror the live draft value and explain the emitted change signal clearly.

The browser should keep both the `Meaningful Interaction Story` panel and the
`Canonical Signal Preview` panel visible while you review the example.

## Aggregate Demo

Review this widget from the aggregate overview in `examples/demo/`.

This example appears in the aggregate demo categories:
Forms and Input, Signal Lab

## Validate

`mix test`

Shared suite support lives in `../shared`.
