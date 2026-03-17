# Unified Examples Demo

This standalone Phoenix LiveView app will host the aggregate category-oriented
demo for the unified examples suite.

Phase 1 establishes the app scaffold, root screen backbone, and launch
contract. Later phases will add the tabbed category galleries and the dedicated
signal lab.

The app already reuses the same shared theme and style baseline as the current
button example and exposes the ordered category registry backbone for the
aggregate review flow.

## Run

From this directory:

`mix deps.get`
`mix phx.server`

The app mounts at `http://127.0.0.1:4000/` by default. Override the port with
`PORT=4100 mix phx.server`.

From `../shared`, you can also preview the launch contract with:

`mix examples.launch demo --dry-run`

## Validate

`mix test`

Shared suite support lives in `../shared`.
