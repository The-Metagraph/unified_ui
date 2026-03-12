defmodule LiveUi.Specs.CheckerTest do
  use ExUnit.Case, async: true

  alias LiveUi.Specs.Checker
  alias LiveUi.Specs.Parser

  test "returns pass for a fully governed subject with satisfied verification targets" do
    tmpdir = make_tmpdir!()
    write_file!(tmpdir, "docs/governance.md", "# governance\n")
    write_file!(tmpdir, "test/example_subject_test.exs", "defmodule ExampleSubjectTest do\nend\n")

    documents = [
      parse_policy(tmpdir, "policy.live_ui_governance"),
      parse_policy(tmpdir, "policy.live_ui_conformance"),
      parse_subject(tmpdir, "docs/governance.md", "test/example_subject_test.exs")
    ]

    report = Checker.check_documents(documents, root: tmpdir, today: ~D[2026-03-10])
    statuses = Map.new(report.subjects, &{&1.subject_id, &1.status})

    assert statuses["policy.live_ui_governance"] == "pass"
    assert statuses["policy.live_ui_conformance"] == "pass"
    assert statuses["module.example_subject"] == "pass"
  end

  test "returns warn when a test verification target is missing" do
    tmpdir = make_tmpdir!()
    write_file!(tmpdir, "docs/governance.md", "# governance\n")

    documents = [
      parse_policy(tmpdir, "policy.live_ui_governance"),
      parse_policy(tmpdir, "policy.live_ui_conformance"),
      parse_subject(tmpdir, "docs/governance.md", "test/missing_subject_test.exs")
    ]

    report = Checker.check_documents(documents, root: tmpdir, today: ~D[2026-03-10])
    subject = Enum.find(report.subjects, &(&1.subject_id == "module.example_subject"))

    assert subject.status == "warn"
    assert Enum.any?(subject.verification_checks, &(&1.status == "warn"))
  end

  test "returns fail when an exception waiver is expired" do
    tmpdir = make_tmpdir!()
    write_file!(tmpdir, "docs/governance.md", "# governance\n")
    write_file!(tmpdir, "test/example_subject_test.exs", "defmodule ExampleSubjectTest do\nend\n")

    documents = [
      parse_policy(tmpdir, "policy.live_ui_governance"),
      parse_policy(tmpdir, "policy.live_ui_conformance"),
      parse_subject(tmpdir, "docs/governance.md", "test/example_subject_test.exs", expired?: true)
    ]

    report = Checker.check_documents(documents, root: tmpdir, today: ~D[2026-03-10])
    subject = Enum.find(report.subjects, &(&1.subject_id == "module.example_subject"))

    assert subject.status == "fail"

    assert Enum.any?(subject.governance_checks, fn check ->
             check.control_id == "exception_not_expired" and check.status == "fail"
           end)
  end

  test "returns fail when covers references point at unknown requirements" do
    tmpdir = make_tmpdir!()
    write_file!(tmpdir, "docs/governance.md", "# governance\n")
    write_file!(tmpdir, "test/example_subject_test.exs", "defmodule ExampleSubjectTest do\nend\n")

    bad_subject =
      parse_subject(tmpdir, "docs/governance.md", "test/example_subject_test.exs",
        invalid_covers?: true
      )

    report =
      Checker.check_documents(
        [
          parse_policy(tmpdir, "policy.live_ui_governance"),
          parse_policy(tmpdir, "policy.live_ui_conformance"),
          bad_subject
        ],
        root: tmpdir,
        today: ~D[2026-03-10]
      )

    subject = Enum.find(report.subjects, &(&1.subject_id == "module.example_subject"))

    assert subject.status == "fail"

    assert Enum.any?(subject.governance_checks, fn check ->
             check.control_id == "scenario_covers_valid" and check.status == "fail"
           end)
  end

  defp parse_policy(tmpdir, policy_id) do
    Parser.parse_document(
      policy_source(policy_id),
      Path.join(tmpdir, ".spec/specs/#{policy_id}.spec.md")
    )
  end

  defp parse_subject(tmpdir, doc_target, test_target, opts \\ []) do
    invalid_covers = Keyword.get(opts, :invalid_covers?, false)
    expires_on = if Keyword.get(opts, :expired?, false), do: "2026-01-01", else: "2026-12-31"

    scenario_covers =
      if invalid_covers, do: ["example.unknown_requirement"], else: ["example.requirement"]

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
          "requires": [{"artifacts": ["docs/governance.md"]}],
          "severity": "error"
        }
      ],
      "approval": {"required": true, "roles": ["maintainer"]},
      "gates": [{"id": "local_spec_check", "kind": "mix_task", "target": "mix live_ui.spec.check", "mode": "required"}]
    }
    ```

    ```spec-requirements
    [
      {"id": "example.requirement", "statement": "When checked, the example shall comply.", "priority": "must", "stability": "stable"}
    ]
    ```

    ```spec-scenarios
    [
      {"id": "example.scenario", "given": ["a governed subject"], "when": ["the checker runs"], "then": ["it validates covers references"], "covers": #{Jason.encode!(scenario_covers)}}
    ]
    ```

    ```spec-verification
    [
      {"kind": "doc", "target": #{Jason.encode!(doc_target)}, "covers": ["example.requirement"]},
      {"kind": "test_file", "target": #{Jason.encode!(test_target)}, "covers": ["example.requirement"]},
      {"kind": "command", "target": "mix live_ui.spec.check", "covers": ["example.requirement"]}
    ]
    ```

    ```spec-exceptions
    [
      {"id": "example.waiver", "reason": "Temporary deviation.", "covers": ["example.requirement"], "expires_on": #{Jason.encode!(expires_on)}, "approval_ref": "ADR-0001"}
    ]
    ```
    """

    Parser.parse_document(source, Path.join(tmpdir, ".spec/specs/module.example_subject.spec.md"))
  end

  defp policy_source(policy_id) do
    """
    # Policy

    ```spec-meta
    {
      "id": #{Jason.encode!(policy_id)},
      "kind": "policy",
      "status": "draft",
      "surface": ["local policy"]
    }
    ```

    ```spec-governance
    {
      "owner": "team.live_ui",
      "criticality": "high",
      "primary_plane": "package",
      "change_rules": [
        {
          "id": "policy_rule",
          "when": {"change_types": ["policy_shape"]},
          "requires": [{"artifacts": ["docs/governance.md"]}],
          "severity": "error"
        }
      ],
      "approval": {"required": true, "roles": ["maintainer"]},
      "gates": [{"id": "local_spec_check", "kind": "mix_task", "target": "mix live_ui.spec.check", "mode": "required"}]
    }
    ```

    ```spec-requirements
    [
      {"id": #{Jason.encode!("#{policy_id}.requirement")}, "statement": "When checked, the policy shall be valid.", "priority": "must", "stability": "stable"}
    ]
    ```

    ```spec-scenarios
    [
      {"id": #{Jason.encode!("#{policy_id}.scenario")}, "given": ["a local policy"], "when": ["the checker runs"], "then": ["the policy passes"], "covers": [#{Jason.encode!("#{policy_id}.requirement")}]}
    ]
    ```

    ```spec-verification
    [
      {"kind": "command", "target": "mix live_ui.spec.check", "covers": [#{Jason.encode!("#{policy_id}.requirement")}]}
    ]
    ```
    """
  end

  defp make_tmpdir! do
    path = Path.join(System.tmp_dir!(), "live_ui_specs_#{System.unique_integer([:positive])}")
    File.mkdir_p!(path)
    path
  end

  defp write_file!(root, relative_path, contents) do
    path = Path.join(root, relative_path)
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, contents)
    path
  end
end
