# Unified Examples Radio group

This standalone Phoenix LiveView app demonstrates the `radio_group` widget through the shared example-suite DSL template, theme, and style profile.

It uses source-driven interaction storytelling so reviewers can understand both the browser-visible outcome and the canonical signal meaning.

## Run

From this directory:

`mix deps.get`
`mix phx.server`

The app mounts at `http://127.0.0.1:4000/` by default. Override the port with
`PORT=4100 mix phx.server`.

## Try It

Interact with the radio group example to see how its authored selection signal updates the shared review story.



## Expect

The review panel should explain how the radio group example turns live form input into a browser-visible selection outcome.

The browser should keep both the `Meaningful Interaction Story` panel and the
`Canonical Signal Preview` panel visible while you review the example.

## Validate

`mix test`

Shared suite support lives in `../shared`.
