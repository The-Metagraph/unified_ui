defmodule LiveUi.Specs.ParserTest do
  use ExUnit.Case, async: true

  alias LiveUi.Specs.Parser

  test "parses local governance blocks and waiver-style exceptions" do
    source = """
    # Example Subject

    ```spec-meta
    {
      "id": "module.example_subject",
      "kind": "module",
      "status": "draft",
      "surface": ["Example.Subject"],
      "relationships": [
        {"kind": "governed_by", "target": "policy.live_ui_governance"},
        {"kind": "governed_by", "target": "policy.live_ui_conformance"}
      ]
    }
    ```

    ```spec-governance
    {
      "owner": "team.live_ui",
      "criticality": "high",
      "primary_plane": "execution",
      "change_rules": [
        {
          "id": "example_rule",
          "when": {"change_types": ["behavior_shape"]},
          "requires": [{"artifacts": ["docs/spec-governance.md"]}],
          "severity": "error"
        }
      ],
      "approval": {"required": true, "roles": ["maintainer"]},
      "gates": [{"id": "local_spec_check", "kind": "mix_task", "target": "mix live_ui.spec.check", "mode": "required"}]
    }
    ```

    ```spec-requirements
    [
      {"id": "example.requirement", "statement": "When checked, the example shall parse.", "priority": "must", "stability": "stable"}
    ]
    ```

    ```spec-scenarios
    [
      {"id": "example.scenario", "given": ["a sample spec"], "when": ["the parser runs"], "then": ["the governance block is parsed"], "covers": ["example.requirement"]}
    ]
    ```

    ```spec-verification
    [
      {"kind": "command", "target": "mix live_ui.spec.check", "covers": ["example.requirement"]}
    ]
    ```

    ```spec-exceptions
    [
      {"id": "example.waiver", "reason": "Temporary deviation.", "covers": ["example.requirement"], "expires_on": "2026-12-31", "approval_ref": "ADR-0001"}
    ]
    ```
    """

    document = Parser.parse_document(source, ".spec/specs/module.example_subject.spec.md")

    assert document.meta["id"] == "module.example_subject"
    assert document.governance["owner"] == "team.live_ui"
    assert document.governance["primary_plane"] == "execution"
    assert hd(document.requirements)["id"] == "example.requirement"
    assert hd(document.exceptions)["approval_ref"] == "ADR-0001"
  end
end
