defmodule Mix.Tasks.SpecTasksTest do
  use ExUnit.Case, async: false

  alias Mix.Tasks.Spec.{Compliance, Plancheck}

  import ExUnit.CaptureIO
  import SpecComplianceTestSupport

  setup do
    Mix.Task.clear()
    :ok
  end

  test "spec.plancheck task succeeds for a valid fixture workspace" do
    root = tmp_root!("task_plancheck")
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

    write_json!(
      root,
      ".spec/planning/demo/spec-traceability.json",
      manifest
    )

    write_traceability_markdown!(root, "demo", manifest)

    output =
      capture_io(fn ->
        Mix.Task.reenable("spec.plancheck")
        Plancheck.run(["demo", "--root", root])
      end)

    assert output =~ "package=demo"
    assert output =~ "status=pass"
  end

  test "spec.compliance task fails for a planned fixture workspace" do
    root = tmp_root!("task_compliance")
    write_minimal_plan_docs!(root, "demo")

    write_json!(
      root,
      ".spec/state.json",
      state([requirement("demo.package.one", ".spec/specs/demo/package.spec.md")])
    )

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

    write_json!(
      root,
      ".spec/conformance/demo/manifest.json",
      conformance_manifest("demo", [concrete_requirement("demo.package.one", "planned")])
    )

    assert_raise Mix.Error, fn ->
      capture_io(fn ->
        Mix.Task.reenable("spec.compliance")
        Compliance.run(["demo", "--root", root, "--no-run-commands"])
      end)
    end
  end

  test "spec tasks reject invalid arguments" do
    assert_raise Mix.Error, fn ->
      Mix.Task.reenable("spec.plancheck")
      Plancheck.run([])
    end

    assert_raise Mix.Error, fn ->
      Mix.Task.reenable("spec.compliance")
      Compliance.run([])
    end
  end

  test "spec.plancheck supports json output and file export" do
    root = tmp_root!("task_plancheck_json")
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

    output =
      capture_io(fn ->
        Mix.Task.reenable("spec.plancheck")

        Plancheck.run([
          "demo",
          "--root",
          root,
          "--format",
          "json",
          "--output",
          "tmp/plancheck.json"
        ])
      end)

    assert output =~ "wrote spec.plancheck report"

    payload =
      root
      |> Path.join("tmp/plancheck.json")
      |> File.read!()
      |> JSON.decode!()

    assert payload["kind"] == "plancheck"
    assert payload["status"] == "pass"
  end
end
