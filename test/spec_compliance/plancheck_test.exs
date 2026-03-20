defmodule Unified.SpecCompliance.PlancheckTest do
  use ExUnit.Case, async: true

  alias Unified.SpecCompliance.Plancheck

  import SpecComplianceTestSupport

  test "computes applicable requirements from direct, inherited, upstream, and non-applicable sets" do
    root = tmp_root!("applicable")
    write_minimal_plan_docs!(root, "demo")

    requirements = [
      requirement("demo.package.direct", ".spec/specs/demo/package.spec.md"),
      requirement(
        "ecosystem.architecture.shared_transport_contract",
        ".spec/specs/architecture.spec.md"
      ),
      requirement(
        "unified_ui.signals.canonical_descriptor_shape",
        ".spec/specs/unified-ui/signals.spec.md"
      ),
      requirement(
        "ecosystem.signal_transport.live_bridge",
        ".spec/specs/signal_transport.spec.md"
      )
    ]

    write_json!(root, ".spec/state.json", state(requirements))

    manifest =
      plan_manifest("demo",
        inherited_requirement_ids: ["ecosystem.architecture.shared_transport_contract"],
        upstream_requirement_ids: ["unified_ui.signals.canonical_descriptor_shape"],
        non_applicable_requirement_ids: ["ecosystem.signal_transport.live_bridge"],
        mappings: [
          mapping("demo.package.direct", "direct", ".spec/specs/demo/package.spec.md", ["1.1.1"]),
          mapping(
            "ecosystem.architecture.shared_transport_contract",
            "inherited",
            ".spec/specs/architecture.spec.md",
            ["1.1.1"]
          ),
          mapping(
            "unified_ui.signals.canonical_descriptor_shape",
            "upstream_constraint",
            ".spec/specs/unified-ui/signals.spec.md",
            ["1.1.1"]
          )
        ]
      )

    write_json!(
      root,
      ".spec/planning/demo/spec-traceability.json",
      manifest
    )

    write_traceability_markdown!(root, "demo", manifest)

    report = Plancheck.run("demo", root: root)

    assert report.status == :pass
    assert report.summary.applicable_requirements == 3
  end

  test "fails when a direct requirement is missing from the plan manifest" do
    root = tmp_root!("missing_mapping")
    write_minimal_plan_docs!(root, "demo")

    write_json!(
      root,
      ".spec/state.json",
      state([
        requirement("demo.package.one", ".spec/specs/demo/package.spec.md"),
        requirement("demo.package.two", ".spec/specs/demo/package.spec.md")
      ])
    )

    manifest =
      plan_manifest("demo",
        mappings: [
          mapping("demo.package.one", "direct", ".spec/specs/demo/package.spec.md", ["1.1.1"])
        ]
      )

    write_json!(
      root,
      ".spec/planning/demo/spec-traceability.json",
      manifest
    )

    write_traceability_markdown!(root, "demo", manifest)

    report = Plancheck.run("demo", root: root)

    assert report.status == :fail
    assert Enum.any?(report.findings, &(&1.code == "missing_mapping"))
  end

  test "fails on duplicate mappings, unknown requirements, and invalid plan refs" do
    root = tmp_root!("invalid_plan")
    write_minimal_plan_docs!(root, "demo")

    write_json!(
      root,
      ".spec/state.json",
      state([requirement("demo.package.one", ".spec/specs/demo/package.spec.md")])
    )

    manifest =
      plan_manifest("demo",
        mappings: [
          mapping("demo.package.one", "direct", ".spec/specs/demo/package.spec.md", ["1.1.1"]),
          mapping("demo.package.one", "direct", ".spec/specs/demo/package.spec.md", ["9.9.9"]),
          mapping("demo.package.ghost", "direct", ".spec/specs/demo/package.spec.md", ["1.1.1"])
        ]
      )

    write_json!(
      root,
      ".spec/planning/demo/spec-traceability.json",
      manifest
    )

    write_traceability_markdown!(root, "demo", manifest)

    report = Plancheck.run("demo", root: root)

    assert report.status == :fail
    assert Enum.any?(report.findings, &(&1.code == "duplicate_mapping"))
    assert Enum.any?(report.findings, &(&1.code == "unknown_mapping_requirement_id"))
    assert Enum.any?(report.findings, &(&1.code == "invalid_plan_ref"))
  end

  test "fails when generated traceability markdown drifts from the authoritative json" do
    root = tmp_root!("traceability_drift")
    write_minimal_plan_docs!(root, "demo")

    write_json!(
      root,
      ".spec/state.json",
      state([requirement("demo.package.one", ".spec/specs/demo/package.spec.md")])
    )

    manifest =
      plan_manifest("demo",
        mappings: [
          mapping("demo.package.one", "direct", ".spec/specs/demo/package.spec.md", ["1.1.1"])
        ]
      )

    write_json!(root, ".spec/planning/demo/spec-traceability.json", manifest)
    write_traceability_markdown!(root, "demo", manifest)
    write_file!(root, ".spec/planning/demo/spec-traceability.md", "# drifted\n")

    report = Plancheck.run("demo", root: root)

    assert report.status == :fail
    assert Enum.any?(report.findings, &(&1.code == "traceability_markdown_drift"))
  end
end
