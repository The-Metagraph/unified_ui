# Unified Examples Image

This standalone Phoenix LiveView app demonstrates the `image` widget through the shared example-suite DSL template, theme, and style profile.

It uses target-driven interaction storytelling so reviewers can understand both the browser-visible outcome and the canonical signal meaning.

## Run

From this directory:

`mix deps.get`
`mix phx.server`

The app mounts at `http://127.0.0.1:5000/` by default. Override the port with
`PORT=5100 mix phx.server`.

## Try It

Use the shared trigger to spotlight the image example and review how the authored media is framed.

If the example uses the shared trigger, click `Highlight the image story`.

## Expect

The image example should make the media block feel intentional and show how passive visuals still participate in a meaningful interaction story.

The browser should keep both the `Meaningful Interaction Story` panel and the
`Canonical Signal Preview` panel visible while you review the example.

## Validate

`mix test`
