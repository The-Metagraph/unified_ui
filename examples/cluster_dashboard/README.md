# Unified Examples Cluster dashboard

This standalone Phoenix LiveView app demonstrates the `cluster_dashboard` widget through the shared example-suite DSL template, theme, and style profile.

It uses target-driven interaction storytelling so reviewers can understand both the browser-visible outcome and the canonical signal meaning.

## Run

From this directory:

`mix deps.get`
`mix phx.server`

The app mounts at `http://127.0.0.1:4000/` by default. Override the port with
`PORT=4100 mix phx.server`.

## Try It

Use the shared trigger to see how the cluster dashboard example explains command intent and the resulting reviewed command outcome.

If the example uses the shared trigger, click `Review the cluster dashboard command story`.

## Expect

The review panel should explain how the cluster dashboard example turns an authored canonical interaction into a browser-visible command story reviewers can follow quickly.

The browser should keep both the `Meaningful Interaction Story` panel and the
`Canonical Signal Preview` panel visible while you review the example.

## Validate

`mix test`

Shared suite support lives in `../shared`.
