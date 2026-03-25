defmodule Unified.SpecCompliance.ComplianceTest do
  use ExUnit.Case, async: false
  @moduletag timeout: 180_000

  alias Unified.SpecCompliance.Compliance

  import SpecComplianceTestSupport

  setup_all do
    ensure_spec_state!()
    :ok
  end

  test "fails when the conformance manifest is missing a requirement entry" do
    root = tmp_root!("missing_entry")
    write_minimal_plan_docs!(root, "demo")

    requirements = [requirement("demo.package.one", ".spec/specs/demo/package.spec.md")]
    write_json!(root, ".spec/state.json", state(requirements))

    plan_manifest =
      plan_manifest("demo",
        mappings: [
          mapping("demo.package.one", "direct", ".spec/specs/demo/package.spec.md", ["1.1.1"])
        ]
      )

    write_json!(
      root,
      ".spec/planning/demo/spec-traceability.json",
      plan_manifest
    )

    write_traceability_markdown!(root, "demo", plan_manifest)

    write_json!(root, ".spec/conformance/demo/manifest.json", conformance_manifest("demo", []))

    report = Compliance.run("demo", root: root, run_commands: false)

    assert report.status == :fail
    assert Enum.any?(report.findings, &(&1.code == "missing_requirement_entry"))
  end

  test "rejects alias chains and cycles" do
    root = tmp_root!("alias_cycle")
    write_minimal_plan_docs!(root, "demo")

    requirements = [
      requirement("demo.package.one", ".spec/specs/demo/package.spec.md"),
      requirement("demo.package.two", ".spec/specs/demo/package.spec.md")
    ]

    write_json!(root, ".spec/state.json", state(requirements))

    plan_manifest =
      plan_manifest("demo",
        mappings: [
          mapping("demo.package.one", "direct", ".spec/specs/demo/package.spec.md", ["1.1.1"]),
          mapping("demo.package.two", "direct", ".spec/specs/demo/package.spec.md", ["1.1.1"])
        ]
      )

    write_json!(
      root,
      ".spec/planning/demo/spec-traceability.json",
      plan_manifest
    )

    write_traceability_markdown!(root, "demo", plan_manifest)

    write_json!(
      root,
      ".spec/conformance/demo/manifest.json",
      conformance_manifest("demo", [
        alias_requirement("demo.package.one", "demo.package.two"),
        alias_requirement("demo.package.two", "demo.package.one")
      ])
    )

    report = Compliance.run("demo", root: root, run_commands: false)

    assert report.status == :fail
    assert Enum.any?(report.findings, &(&1.code == "alias_target_not_concrete"))
  end

  test "reports expired waivers and failing command evidence" do
    root = tmp_root!("waiver_and_command")
    write_minimal_plan_docs!(root, "demo")

    requirements = [
      requirement("demo.package.one", ".spec/specs/demo/package.spec.md"),
      requirement("demo.package.two", ".spec/specs/demo/package.spec.md")
    ]

    write_json!(root, ".spec/state.json", state(requirements))

    plan_manifest =
      plan_manifest("demo",
        mappings: [
          mapping("demo.package.one", "direct", ".spec/specs/demo/package.spec.md", ["1.1.1"]),
          mapping("demo.package.two", "direct", ".spec/specs/demo/package.spec.md", ["1.1.1"])
        ]
      )

    write_json!(
      root,
      ".spec/planning/demo/spec-traceability.json",
      plan_manifest
    )

    write_traceability_markdown!(root, "demo", plan_manifest)

    write_json!(
      root,
      ".spec/conformance/demo/manifest.json",
      conformance_manifest("demo", [
        %{
          "requirement_id" => "demo.package.one",
          "status" => "waived",
          "waiver" => %{
            "reason" => "intentional",
            "approved_by" => "tester",
            "approved_on" => "2026-03-01",
            "expires_on" => "2026-03-02"
          }
        },
        %{
          "requirement_id" => "demo.package.two",
          "status" => "verified",
          "evidence" => [
            %{
              "kind" => "command",
              "run" => "printf 'nope'",
              "expect_stdout_contains" => "ok"
            }
          ]
        }
      ])
    )

    report = Compliance.run("demo", root: root, run_commands: true)

    assert report.status == :fail
    assert Enum.any?(report.findings, &(&1.code == "waiver_expired"))
    assert Enum.any?(report.findings, &(&1.code == "command_stdout_mismatch"))
  end

  test "live elm_ui plancheck and compliance both pass with full verification" do
    plan_report = Unified.SpecCompliance.plancheck("elm_ui")
    compliance_report = Unified.SpecCompliance.compliance("elm_ui", run_commands: true)

    assert plan_report.status == :pass
    assert compliance_report.status == :pass
    assert compliance_report.summary.applicable_requirements == 89
    assert compliance_report.summary.status_counts.verified == 89
    assert compliance_report.summary.status_counts.waived == 0
    assert compliance_report.summary.status_counts.planned == 0
    assert compliance_report.summary.aliases == 48
    assert compliance_report.summary.waived_requirement_ids == []
    assert compliance_report.summary.waived_source_requirement_ids == []
    assert compliance_report.findings == []
    assert compliance_report.summary.ci_enforcement == "required"

    native_runtime_requirement =
      Enum.find(
        compliance_report.results,
        &(&1.requirement_id == "elm_ui.package.native_runtime_library")
      )

    assert native_runtime_requirement.effective_status == :verified
    assert native_runtime_requirement.compliant?

    refute Enum.any?(
             compliance_report.findings,
             &(&1.requirement_id == "elm_ui.package.traceable_to_root_specs")
           )
  end

  test "live live_ui plancheck and compliance both pass" do
    plan_report = Unified.SpecCompliance.plancheck("live_ui")
    compliance_report = Unified.SpecCompliance.compliance("live_ui", run_commands: true)

    assert plan_report.status == :pass
    assert compliance_report.status == :pass
    assert compliance_report.summary.applicable_requirements == 83
    assert compliance_report.summary.status_counts.verified == 83
    assert compliance_report.summary.aliases == 48
  end

  test "live desktop_ui plancheck and compliance both pass" do
    plan_report = Unified.SpecCompliance.plancheck("desktop_ui")
    compliance_report = Unified.SpecCompliance.compliance("desktop_ui", run_commands: true)

    assert plan_report.status == :pass
    assert compliance_report.status == :pass
    assert compliance_report.summary.applicable_requirements == 102
    assert compliance_report.summary.status_counts.verified == 102
    assert compliance_report.summary.status_counts.waived == 0
    assert compliance_report.summary.aliases == 49
    assert compliance_report.summary.ci_enforcement == "required"
  end

  @tag timeout: 720_000
  test "live unified_ui plancheck and compliance both pass" do
    plan_report = Unified.SpecCompliance.plancheck("unified_ui")
    compliance_report = Unified.SpecCompliance.compliance("unified_ui", run_commands: true)

    assert plan_report.status == :pass
    assert compliance_report.status == :pass
    assert compliance_report.summary.applicable_requirements == 97
    assert compliance_report.summary.status_counts.verified == 97
    assert compliance_report.summary.status_counts.waived == 0
    assert compliance_report.summary.ci_enforcement == "required"
  end

  test "live unified_iur plancheck and compliance both pass" do
    plan_report = Unified.SpecCompliance.plancheck("unified_iur")
    compliance_report = Unified.SpecCompliance.compliance("unified_iur", run_commands: true)

    assert plan_report.status == :pass
    assert compliance_report.status == :pass
    assert compliance_report.summary.applicable_requirements == 62
    assert compliance_report.summary.status_counts.verified == 62
    assert compliance_report.summary.status_counts.waived == 0
    assert compliance_report.summary.aliases == 18
    assert compliance_report.summary.ci_enforcement == "required"
  end

  defp ensure_spec_state! do
    state_path = Path.join(File.cwd!(), ".spec/state.json")

    unless File.exists?(state_path) do
      Mix.Task.reenable("spec.plan")
      Mix.Task.run("spec.plan")
    end
  end
end
