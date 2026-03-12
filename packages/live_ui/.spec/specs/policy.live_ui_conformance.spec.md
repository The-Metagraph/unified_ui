# LiveUi Conformance Policy

This policy subject defines the local conformance expectations for spec parsing, verification target evaluation, and derived compliance reporting.

```spec-meta
{
  "id": "policy.live_ui_conformance",
  "kind": "policy",
  "status": "draft",
  "surface": ["local spec compliance"]
}
```

```spec-governance
{
  "owner": "team.live_ui",
  "criticality": "high",
  "primary_plane": "package",
  "change_rules": [
    {
      "id": "conformance_policy_changes_require_checker_alignment",
      "when": {
        "change_types": ["policy_shape"]
      },
      "requires": [
        {"subject_ids": ["module.live_ui_specs_checker"]}
      ],
      "severity": "error"
    }
  ],
  "approval": {
    "required": true,
    "roles": ["maintainer"]
  },
  "gates": [
    {
      "id": "local_spec_check",
      "kind": "mix_task",
      "target": "mix live_ui.spec.check",
      "mode": "required"
    }
  ]
}
```

## Requirements

```spec-requirements
[
  {
    "id": "live_ui_conformance.report.emits_derived_json",
    "statement": "When the local compliance command runs, it shall emit a derived JSON compliance report under _build/specled/compliance-report.json.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_conformance.covers.references_local_requirements",
    "statement": "When scenarios, verification entries, or exceptions declare covers references, the references shall resolve to requirement ids declared in the same subject document.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_conformance.missing_verification_is_non_passing",
    "statement": "If a doc or test_file verification target does not exist, then the local compliance report shall mark that verification as non-passing rather than silently treating it as satisfied.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_conformance.failure_vs_warning_status",
    "statement": "When compliance is summarized locally, the report shall use fail for governance or covers integrity violations and warn for unresolved verification targets.",
    "priority": "must",
    "stability": "stable"
  }
]
```

## Scenarios

```spec-scenarios
[
  {
    "id": "live_ui_conformance.report_written",
    "given": ["a repository containing local spec files"],
    "when": ["mix live_ui.spec.check runs"],
    "then": ["a derived compliance report is written to _build/specled/compliance-report.json"],
    "covers": ["live_ui_conformance.report.emits_derived_json"]
  },
  {
    "id": "live_ui_conformance.invalid_covers_reference",
    "given": ["a scenario, verification, or exception entry that names an unknown requirement id"],
    "when": ["the checker validates the document"],
    "then": ["the subject fails compliance instead of silently accepting the bad reference"],
    "covers": [
      "live_ui_conformance.covers.references_local_requirements",
      "live_ui_conformance.failure_vs_warning_status"
    ]
  },
  {
    "id": "live_ui_conformance.missing_test_target",
    "given": ["a verification entry pointing at a missing test file"],
    "when": ["the checker evaluates verification targets"],
    "then": ["the verification is marked non-passing with warn status"],
    "covers": [
      "live_ui_conformance.missing_verification_is_non_passing",
      "live_ui_conformance.failure_vs_warning_status"
    ]
  }
]
```

## Verification

```spec-verification
[
  {
    "kind": "doc",
    "target": "docs/spec-governance.md",
    "covers": [
      "live_ui_conformance.report.emits_derived_json",
      "live_ui_conformance.covers.references_local_requirements",
      "live_ui_conformance.missing_verification_is_non_passing",
      "live_ui_conformance.failure_vs_warning_status"
    ]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/specs/checker_test.exs",
    "covers": [
      "live_ui_conformance.covers.references_local_requirements",
      "live_ui_conformance.missing_verification_is_non_passing",
      "live_ui_conformance.failure_vs_warning_status"
    ]
  },
  {
    "kind": "command",
    "target": "mix live_ui.spec.check",
    "covers": [
      "live_ui_conformance.report.emits_derived_json",
      "live_ui_conformance.covers.references_local_requirements"
    ]
  }
]
```
