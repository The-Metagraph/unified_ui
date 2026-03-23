# `.spec/conformance`

This folder contains machine-readable package implementation conformance
manifests.

## Purpose

- planning coverage stays with the relevant package plan under
  `.spec/planning/<package>/spec-traceability.json`
- generated review-facing traceability mirrors live alongside that JSON under
  `.spec/planning/<package>/spec-traceability.md`
- implementation evidence lives here under
  `.spec/conformance/<package>/manifest.json`
- governance contracts remain separate and define policy rather than evidence

## Current Use

- `elm_ui`, `live_ui`, `unified_ui`, and `unified_iur` are seeded packages in this layer
- `mix spec.plancheck <package>` validates machine-readable plan coverage
- `mix spec.traceability.generate <package>` regenerates the markdown mirror
- `mix spec.compliance <package>` validates implementation evidence against the
  same applicable requirement set
- `mix spec.compliance.ci` evaluates changed-package compliance using package
  `ci_enforcement` metadata

## Conventions

- manifests are JSON objects keyed by package
- requirement ids must come from `.spec/state.json`
- implementation manifests do not duplicate plan refs; they join to the plan
  manifest by `requirement_id`
- implementation manifests must declare `ci_enforcement` as `warn` or
  `required`
- plan coverage JSON is authoritative; the markdown mirror is generated review
  output and should be refreshed through `mix spec.traceability.generate`
