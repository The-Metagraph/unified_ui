# Unified Examples Box

This standalone Phoenix LiveView app demonstrates the `box` widget through the shared example-suite DSL template, theme, and style profile.

It uses target-driven interaction storytelling so reviewers can understand both the browser-visible outcome and the canonical signal meaning.

## Run

From this directory:

`mix deps.get`
`mix phx.server`

The app mounts at `http://127.0.0.1:4000/` by default. Override the port with
`PORT=4100 mix phx.server`.

## Try It

Use the shared trigger to highlight how the box example frames spacing, grouping, and visual boundary choices.

If the example uses the shared trigger, click `Review the box layout story`.

## Expect

The box example should make the authored layout container feel intentional and easy to review in the browser.

The browser should keep both the `Meaningful Interaction Story` panel and the
`Canonical Signal Preview` panel visible while you review the example.

## Validate

`mix test`

Shared suite support lives in `../shared`.
