# Unified Examples Button

This standalone Phoenix LiveView app demonstrates the `button` widget through the shared example-suite DSL template, theme, and style profile.

It uses source-driven interaction storytelling so reviewers can understand both the browser-visible outcome and the canonical signal meaning.

## Run

From this directory:

`mix deps.get`
`mix phx.server`

The app mounts at `http://127.0.0.1:4000/` by default. Override the port with
`PORT=4100 mix phx.server`.

## Try It

Click Save profile to emit the authored canonical button signal.



## Expect

The button example should make the primary action feel live and explain the emitted click signal in reviewer-friendly language.

The browser should keep both the `Meaningful Interaction Story` panel and the
`Canonical Signal Preview` panel visible while you review the example.

## Aggregate Demo

Review this widget from the aggregate overview in `examples/demo/`.

This example appears in the aggregate demo categories:
Foundational Content, Signal Lab

## Validate

`mix test`

Shared suite support lives in `../shared`.
