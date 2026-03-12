# LiveUi Specs Checker

The specs checker subject defines the local parser, compliance evaluator, and Mix task used to govern `.spec/specs/*.spec.md` files inside this repository.

This subject is intentionally local to `live_ui`. It implements the proposed governance/compliance split without requiring upstream changes to the broader Spec Led system.

```spec-meta
{
  "id": "module.live_ui_specs_checker",
  "kind": "module",
  "status": "draft",
  "surface": ["LiveUi.Specs", "LiveUi.Specs.Parser", "LiveUi.Specs.Checker", "LiveUi.Specs.ComplianceReport", "Mix.Tasks.LiveUi.Spec.Check"],
  "relationships": [
    {"kind": "depends_on", "target": "package.live_ui"},
    {"kind": "depends_on", "target": "policy.live_ui_governance"},
    {"kind": "depends_on", "target": "policy.live_ui_conformance"},
    {"kind": "governed_by", "target": "policy.live_ui_governance"},
    {"kind": "governed_by", "target": "policy.live_ui_conformance"}
  ]
}
```

```spec-governance
{
  "owner": "team.live_ui",
  "criticality": "high",
  "primary_plane": "package",
  "change_rules": [
    {
      "id": "checker_behavior_requires_policy_alignment",
      "when": {
        "change_types": ["behavior_shape"]
      },
      "requires": [
        {"subject_ids": ["policy.live_ui_governance", "policy.live_ui_conformance"]},
        {"artifacts": ["docs/spec-governance.md"]}
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
    "id": "live_ui_specs_checker.parses_governance_block",
    "statement": "When a local spec document contains a spec-governance block, the checker shall parse that JSON block alongside meta, requirements, scenarios, verification, and exceptions.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_specs_checker.validates_governance_structure",
    "statement": "When local specs are checked, the checker shall validate governance block presence, governed_by policy relationships, primary_plane, approval policy, gates, change rules, and waiver hygiene.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_specs_checker.writes_compliance_report",
    "statement": "When the checker completes, it shall emit a derived compliance report JSON document containing subject status, governance checks, verification checks, active exceptions, and findings.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_specs_checker.exposes_mix_task",
    "statement": "When local developers or CI need to evaluate spec compliance, the repository shall expose a mix live_ui.spec.check command that writes the report and exits non-zero on failures.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_specs_checker.strict_mode_escalates_warnings",
    "statement": "When mix live_ui.spec.check is invoked with strict mode, the command shall also exit non-zero when warnings remain unresolved.",
    "priority": "should",
    "stability": "stable"
  }
]
```

## Scenarios

```spec-scenarios
[
  {
    "id": "live_ui_specs_checker.parses_local_document",
    "given": ["a local spec file containing spec-meta and spec-governance blocks"],
    "when": ["the parser reads the file"],
    "then": ["the parsed document contains governance metadata in addition to the standard Spec Led blocks"],
    "covers": ["live_ui_specs_checker.parses_governance_block"]
  },
  {
    "id": "live_ui_specs_checker.report_generation",
    "given": ["a repository with local spec files"],
    "when": ["mix live_ui.spec.check runs"],
    "then": ["a compliance report JSON document is written under _build/specled and includes subject status, checks, findings, and active exceptions"],
    "covers": [
      "live_ui_specs_checker.writes_compliance_report",
      "live_ui_specs_checker.exposes_mix_task"
    ]
  },
  {
    "id": "live_ui_specs_checker.strict_mode",
    "given": ["a repository whose verification targets still contain warnings"],
    "when": ["mix live_ui.spec.check --strict runs"],
    "then": ["the command exits non-zero instead of silently accepting the warnings"],
    "covers": ["live_ui_specs_checker.strict_mode_escalates_warnings"]
  },
  {
    "id": "live_ui_specs_checker.invalid_governance",
    "given": ["a local subject missing required governance metadata or policy relationships"],
    "when": ["the checker evaluates the subject"],
    "then": ["the subject fails compliance with explicit governance findings"],
    "covers": ["live_ui_specs_checker.validates_governance_structure"]
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
      "live_ui_specs_checker.parses_governance_block",
      "live_ui_specs_checker.validates_governance_structure",
      "live_ui_specs_checker.writes_compliance_report",
      "live_ui_specs_checker.exposes_mix_task",
      "live_ui_specs_checker.strict_mode_escalates_warnings"
    ]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/specs/parser_test.exs",
    "covers": ["live_ui_specs_checker.parses_governance_block"]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/specs/checker_test.exs",
    "covers": [
      "live_ui_specs_checker.validates_governance_structure",
      "live_ui_specs_checker.writes_compliance_report"
    ]
  },
  {
    "kind": "command",
    "target": "mix live_ui.spec.check",
    "covers": [
      "live_ui_specs_checker.writes_compliance_report",
      "live_ui_specs_checker.exposes_mix_task",
      "live_ui_specs_checker.strict_mode_escalates_warnings"
    ]
  }
]
```
