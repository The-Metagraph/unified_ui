defmodule Unified.SpecCompliance.ComplianceTest do
  use ExUnit.Case, async: true

  alias Unified.SpecCompliance.Compliance

  import SpecComplianceTestSupport

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

  test "live web_ui plancheck passes and compliance reports a reset-aware waived state" do
    plan_report = Unified.SpecCompliance.plancheck("web_ui")
    compliance_report = Unified.SpecCompliance.compliance("web_ui", run_commands: true)

    assert plan_report.status == :pass
    assert compliance_report.status == :pass
    assert compliance_report.summary.applicable_requirements == 89
    assert compliance_report.summary.status_counts.verified == 10
    assert compliance_report.summary.status_counts.waived == 79
    assert compliance_report.summary.status_counts.planned == 0
    assert compliance_report.summary.aliases == 48
    assert compliance_report.findings == []

    native_runtime_requirement =
      Enum.find(
        compliance_report.results,
        &(&1.requirement_id == "web_ui.package.native_runtime_library")
      )

    assert native_runtime_requirement.effective_status == :waived
    assert native_runtime_requirement.compliant?

    refute Enum.any?(
             compliance_report.findings,
             &(&1.requirement_id == "web_ui.package.traceable_to_root_specs")
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
end
