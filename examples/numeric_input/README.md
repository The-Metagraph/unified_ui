# Unified Examples Numeric input

This standalone Phoenix LiveView app demonstrates the `numeric_input` widget through the shared example-suite DSL template, theme, and style profile.

It uses source-driven interaction storytelling so reviewers can understand both the browser-visible outcome and the canonical signal meaning.

## Run

From this directory:

`mix deps.get`
`mix phx.server`

The app mounts at `http://127.0.0.1:4000/` by default. Override the port with
`PORT=4100 mix phx.server`.

## Try It

Interact with the numeric input example to see how its authored change signal updates the shared review story.



## Expect

The review panel should explain how the numeric input example turns live form input into a browser-visible change outcome.

The browser should keep both the `Meaningful Interaction Story` panel and the
`Canonical Signal Preview` panel visible while you review the example.

## Validate

`mix test`

Shared suite support lives in `../shared`.
