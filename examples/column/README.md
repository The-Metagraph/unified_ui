# Unified Examples Column

This standalone Phoenix LiveView app demonstrates the `column` widget through the shared example-suite DSL template, theme, and style profile.

It uses target-driven interaction storytelling so reviewers can understand both the browser-visible outcome and the canonical signal meaning.

## Run

From this directory:

`mix deps.get`
`mix phx.server`

The app mounts at `http://127.0.0.1:4000/` by default. Override the port with
`PORT=4100 mix phx.server`.

## Try It

Use the shared trigger to see how the column example explains click changes in the surrounding composition.

If the example uses the shared trigger, click `Review the column layout story`.

## Expect

The review panel should explain how the column example turns an authored canonical interaction into a browser-visible layout story.

The browser should keep both the `Meaningful Interaction Story` panel and the
`Canonical Signal Preview` panel visible while you review the example.

## Validate

`mix test`

Shared suite support lives in `../shared`.
