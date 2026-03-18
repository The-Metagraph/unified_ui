# Unified Examples Demo

This standalone Phoenix LiveView app is the aggregate category-oriented review surface for the unified examples suite.

Use the aggregate demo when you want a category-level overview of the controls,
their shared shell treatment, and the cross-control interaction stories that
tie the suite together. Use the focused `examples/<widget_name>/` apps when you
want to inspect one widget’s authored interaction in detail.

The app reuses the same shared theme and style baseline as the current button
example and keeps that continuity visible across every tab, gallery, and Signal
Lab story. The baseline is anchored to the shared `:example_suite_default`
theme and the same shared shell and panel style profile used by the focused
button example.

## What It Shows

- ordered category tabs for foundational content, forms and input, layout and
  display, navigation and selection, data and feedback, overlays and
  operational, and Signal Lab
- linked example directories for every category so reviewers can move from
  overview to the focused per-widget app quickly
- one dedicated Signal Lab where canonical authored interactions visibly change
  other controls and panels

## Run

From this directory:

`mix deps.get`
`mix phx.server`

The app mounts at `http://127.0.0.1:4000/` by default. Override the port with
`PORT=4100 mix phx.server`.

From `../shared`, you can also preview the launch contract with:

`mix examples.launch demo --dry-run`

## Review

Look for three things when the app is running:

- the selected tab’s linked example directories, which map the category back to
  the focused apps
- the shared shell treatment, which should feel visually continuous with the
  current button example
- the Signal Lab tab, which should show meaningful interaction stories and
  canonical signal previews for cross-control reactivity

## Validate

`mix test`

Shared suite support lives in `../shared`.

## Maintain It

When the examples catalog changes:

1. every focused example directory listed in `examples/catalog.tsv` should remain traceable through at least one category tab and linked example directory list
2. add a new representative control or signal-lab story to the appropriate demo
   category fragment
3. keep the same shared theme and style baseline as the current button example,
   anchored to `:example_suite_default`
4. update the linked example directories and category review copy so the new
   control is traceable from overview to focused app
5. run `mix examples.launch demo --dry-run` from `../shared`
6. run `mix examples.launch demo --smoke-test` from `../shared`
7. run `mix examples.validate --strict` from `../shared`

When the Signal Lab evolves, add a new representative control or signal-lab
story only if it still demonstrates authored `UnifiedUi` interactions compiled
to canonical `UnifiedIUR` and rendered through `LiveUi` with a reviewer-visible
outcome.

When the shared button-example styling baseline changes, update the aggregate
demo shell, tabs, and gallery chrome in the same change so the demo continues
to present the same theme and style contract as the focused suite.
