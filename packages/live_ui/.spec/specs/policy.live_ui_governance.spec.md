# LiveUi Governance Policy

This policy subject defines the local governance rules for authored specs in this repository.

It keeps ownership, control-plane assignment, waiver hygiene, and policy relationships explicit without requiring upstream changes to the Spec Led project.

```spec-meta
{
  "id": "policy.live_ui_governance",
  "kind": "policy",
  "status": "draft",
  "surface": ["local spec governance"]
}
```

```spec-governance
{
  "owner": "team.live_ui",
  "criticality": "high",
  "primary_plane": "package",
  "change_rules": [
    {
      "id": "governance_policy_changes_require_local_documentation",
      "when": {
        "change_types": ["policy_shape"]
      },
      "requires": [
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
    "id": "live_ui_governance.subjects.declare_governance_blocks",
    "statement": "When a non-policy subject is authored in this repository, the subject shall declare a spec-governance block containing owner, criticality, primary_plane, approval policy, gates, and change rules.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_governance.subjects.relate_to_policy_subjects",
    "statement": "When a non-policy subject is authored in this repository, the subject shall declare governed_by relationships to policy.live_ui_governance and policy.live_ui_conformance.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_governance.primary_plane.uses_local_taxonomy",
    "statement": "When a subject declares primary_plane in local governance metadata, the value shall be one of package, integration, execution, or rendering.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_governance.waivers.require_approval",
    "statement": "If an exception functions as a waiver by covering requirements or declaring an expiry, then the exception shall include an approval_ref.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_governance.waivers.expiry_enforced",
    "statement": "If a waiver exception expires, then the local compliance check shall mark the subject as failing rather than silently allowing the waiver to persist.",
    "priority": "must",
    "stability": "stable"
  }
]
```

## Scenarios

```spec-scenarios
[
  {
    "id": "live_ui_governance.valid_non_policy_subject",
    "given": ["a module or package subject in .spec/specs"],
    "when": ["the local checker parses the document"],
    "then": ["the subject contains a governance block and governed_by relationships to both local policy subjects"],
    "covers": [
      "live_ui_governance.subjects.declare_governance_blocks",
      "live_ui_governance.subjects.relate_to_policy_subjects"
    ]
  },
  {
    "id": "live_ui_governance.primary_plane_validation",
    "given": ["a subject with governance metadata"],
    "when": ["the checker validates primary_plane"],
    "then": ["the value is accepted only when it matches the local plane taxonomy"],
    "covers": ["live_ui_governance.primary_plane.uses_local_taxonomy"]
  },
  {
    "id": "live_ui_governance.waiver_validation",
    "given": ["an exception that covers requirements or declares an expiry"],
    "when": ["the checker evaluates waiver metadata"],
    "then": ["approval_ref is required and expired waivers fail compliance"],
    "covers": [
      "live_ui_governance.waivers.require_approval",
      "live_ui_governance.waivers.expiry_enforced"
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
      "live_ui_governance.subjects.declare_governance_blocks",
      "live_ui_governance.subjects.relate_to_policy_subjects",
      "live_ui_governance.primary_plane.uses_local_taxonomy",
      "live_ui_governance.waivers.require_approval",
      "live_ui_governance.waivers.expiry_enforced"
    ]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/specs/checker_test.exs",
    "covers": [
      "live_ui_governance.subjects.declare_governance_blocks",
      "live_ui_governance.subjects.relate_to_policy_subjects",
      "live_ui_governance.primary_plane.uses_local_taxonomy",
      "live_ui_governance.waivers.require_approval",
      "live_ui_governance.waivers.expiry_enforced"
    ]
  },
  {
    "kind": "command",
    "target": "mix live_ui.spec.check",
    "covers": [
      "live_ui_governance.subjects.declare_governance_blocks",
      "live_ui_governance.subjects.relate_to_policy_subjects",
      "live_ui_governance.primary_plane.uses_local_taxonomy",
      "live_ui_governance.waivers.require_approval",
      "live_ui_governance.waivers.expiry_enforced"
    ]
  }
]
```
