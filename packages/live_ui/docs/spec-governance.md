# Local Spec Governance

`live_ui` keeps governance and compliance local to this repository for now.

## Authoring Rules

- every `.spec/specs/*.spec.md` file uses JSON fenced blocks
- every non-policy subject declares a `spec-governance` block
- every non-policy subject is governed by:
  - `policy.live_ui_governance`
  - `policy.live_ui_conformance`
- governance uses one local `primary_plane` value:
  - `package`
  - `integration`
  - `execution`
  - `rendering`

## Schema

- the structural shape of `spec-governance` is documented in [schemas/spec-governance.schema.json](/Users/Pascal/code/unified/live_ui/schemas/spec-governance.schema.json)
- the schema is intentionally structural only
- the local checker remains the authority for:
  - cross-document policy relationships
  - `covers` integrity
  - waiver approval and expiry rules
  - verification target existence

This keeps the format explicit without trying to force all governance semantics into JSON Schema.

## Compliance Rules

- compliance is derived, not authored
- the local checker writes `_build/specled/compliance-report.json`
- governance failures produce `fail`
- missing verification targets produce `warn`
- `mix live_ui.spec.check --strict` also fails on warnings

## Local Command

Run:

```sh
mix live_ui.spec.check
```

The command:

- parses all local spec files
- validates governance structure and `covers` references
- checks doc/test verification target existence
- writes the derived compliance report
