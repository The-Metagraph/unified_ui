# LiveUi Local Specs

This subject backfills the current repo-local governance overlay shipped inside
`packages/live_ui`, based on its parser, checker, report model, and Mix task.

```spec-meta
id: live_ui.local_specs
kind: tooling
status: active
summary: Current local spec-governance overlay contract for `packages/live_ui`, including document parsing, compliance checking, report generation, and the dedicated Mix task entrypoint.
surface:
  - packages/live_ui/lib/live_ui/specs.ex
  - packages/live_ui/lib/live_ui/specs
  - packages/live_ui/lib/mix/tasks/live_ui.spec.check.ex
  - packages/live_ui/test/live_ui/specs
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: live_ui.local_specs.entrypoints
  statement: 'The package shall expose `LiveUi.Specs` as the current public entrypoint for parsing spec documents, running the local compliance check, and writing a JSON-serializable compliance report.'
  priority: must
  stability: stable

- id: live_ui.local_specs.overlay_parser
  statement: 'The package shall parse current Spec Led markdown documents together with the local `spec-governance` block into structured `LiveUi.Specs.Document` values.'
  priority: must
  stability: stable

- id: live_ui.local_specs.compliance_checker
  statement: 'The package shall evaluate the current local governance overlay by checking required policy subjects, governance metadata, covers integrity, exception lifetimes, verification targets, and derived summary status in a compliance report.'
  priority: must
  stability: stable

- id: live_ui.local_specs.mix_task
  statement: 'The package shall expose `mix live_ui.spec.check` as the current repo-local entrypoint that writes a JSON compliance report and can fail on errors or on warnings in strict mode.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/live_ui/lib/live_ui/specs.ex
  covers:
    - live_ui.local_specs.entrypoints

- kind: source_file
  target: packages/live_ui/lib/live_ui/specs/parser.ex
  covers:
    - live_ui.local_specs.overlay_parser

- kind: source_file
  target: packages/live_ui/lib/live_ui/specs/checker.ex
  covers:
    - live_ui.local_specs.compliance_checker

- kind: source_file
  target: packages/live_ui/lib/mix/tasks/live_ui.spec.check.ex
  covers:
    - live_ui.local_specs.mix_task

- kind: source_file
  target: packages/live_ui/test/live_ui/specs/parser_test.exs
  covers:
    - live_ui.local_specs.overlay_parser

- kind: source_file
  target: packages/live_ui/test/live_ui/specs/checker_test.exs
  covers:
    - live_ui.local_specs.compliance_checker

- kind: source_file
  target: packages/live_ui/lib/live_ui/specs/compliance_report.ex
  covers:
    - live_ui.local_specs.entrypoints
```
