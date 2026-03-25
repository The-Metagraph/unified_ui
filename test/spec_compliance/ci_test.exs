defmodule Unified.SpecCompliance.CITest do
  use ExUnit.Case, async: true

  alias Unified.SpecCompliance.CI

  import SpecComplianceTestSupport

  test "detects only packages affected by changed files" do
    root = tmp_root!("ci_changed_packages")

    ["alpha", "beta"]
    |> Enum.each(fn package ->
      write_minimal_plan_docs!(root, package)

      write_json!(
        root,
        ".spec/state.json",
        state([requirement("#{package}.package.one", ".spec/specs/#{package}/package.spec.md")])
      )

      manifest =
        plan_manifest(package,
          mappings: [
            mapping(
              "#{package}.package.one",
              "direct",
              ".spec/specs/#{package}/package.spec.md",
              ["1.1.1"]
            )
          ]
        )

      write_json!(root, ".spec/planning/#{package}/spec-traceability.json", manifest)
      write_traceability_markdown!(root, package, manifest)

      write_json!(
        root,
        ".spec/conformance/#{package}/manifest.json",
        conformance_manifest(package, [
          concrete_requirement("#{package}.package.one", "verified", [path_exists("README.md")])
        ])
      )

      write_file!(root, ".spec/specs/#{package}/package.spec.md", "# #{package}\n")
    end)

    affected =
      CI.affected_packages(
        root,
        ["alpha", "beta"],
        [".spec/planning/beta/spec-traceability.json"]
      )

    assert affected == ["beta"]
  end

  test "warn packages do not fail the ci report while required packages do" do
    root = tmp_root!("ci_warn_required")
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

    write_json!(
      root,
      ".spec/conformance/demo/manifest.json",
      conformance_manifest("demo", [concrete_requirement("demo.package.one", "planned")], "warn")
    )

    warn_report = Unified.SpecCompliance.ci(root: root, changed_file: "packages/demo/lib/demo.ex")

    assert warn_report.status == :warn

    write_json!(
      root,
      ".spec/conformance/demo/manifest.json",
      conformance_manifest(
        "demo",
        [concrete_requirement("demo.package.one", "planned")],
        "required"
      )
    )

    required_report =
      Unified.SpecCompliance.ci(root: root, changed_file: "packages/demo/lib/demo.ex")

    assert required_report.status == :fail
  end

  test "hyphenated package source paths affect underscore-named packages" do
    root = tmp_root!("ci_hyphenated_package")
    write_minimal_plan_docs!(root, "unified_ui")

    write_json!(
      root,
      ".spec/state.json",
      state([requirement("unified_ui.package.one", ".spec/specs/unified-ui/package.spec.md")])
    )

    manifest =
      plan_manifest("unified_ui",
        mappings: [
          mapping(
            "unified_ui.package.one",
            "direct",
            ".spec/specs/unified-ui/package.spec.md",
            ["1.1.1"]
          )
        ]
      )

    write_json!(root, ".spec/planning/unified_ui/spec-traceability.json", manifest)
    write_traceability_markdown!(root, "unified_ui", manifest)

    write_json!(
      root,
      ".spec/conformance/unified_ui/manifest.json",
      conformance_manifest("unified_ui", [
        concrete_requirement("unified_ui.package.one", "verified", [path_exists("README.md")])
      ])
    )

    write_file!(root, ".spec/specs/unified-ui/package.spec.md", "# unified_ui\n")

    affected =
      CI.affected_packages(
        root,
        ["unified_ui"],
        ["packages/unified-ui/lib/unified_ui.ex"]
      )

    assert affected == ["unified_ui"]
  end

  @tag timeout: 180_000
  test "live desktop_ui package changes are detected and reported by compliance ci" do
    report =
      Unified.SpecCompliance.ci(changed_file: "packages/desktop_ui/lib/desktop_ui/build.ex")

    assert report.status == :pass
    assert report.summary.affected_packages == 1
    assert report.summary.required_failures == 0
    assert report.summary.warn_failures == 0
    assert Enum.map(report.packages, & &1.package) == ["desktop_ui"]
    assert hd(report.packages).ci_enforcement == "required"
  end
end
