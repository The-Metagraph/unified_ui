# `.spec/conformance`

This folder contains machine-readable package implementation conformance
manifests.

## Purpose

- planning coverage stays with the relevant package plan under
  `.spec/planning/<package>/spec-traceability.json`
- implementation evidence lives here under
  `.spec/conformance/<package>/manifest.json`
- governance contracts remain separate and define policy rather than evidence

## Current Use

- `web_ui` is the first seeded package in this layer
- `mix spec.plancheck <package>` validates machine-readable plan coverage
- `mix spec.compliance <package>` validates implementation evidence against the
  same applicable requirement set

## Conventions

- manifests are JSON objects keyed by package
- requirement ids must come from `.spec/state.json`
- implementation manifests do not duplicate plan refs; they join to the plan
  manifest by `requirement_id`
