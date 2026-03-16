defmodule UnifiedExamples.TraceabilityTest do
  use ExUnit.Case, async: false

  alias UnifiedExamples.Shared.Traceability
  alias UnifiedExamples.Shared.Tooling

  @moduletag timeout: 120_000

  test "report exposes the package and spec paths behind the example suite" do
    report = Traceability.report()

    assert report.valid?
    assert report.missing_paths == []
    assert report.packages.unified_ui.package_root =~ "/packages/unified-ui"
    assert report.packages.unified_iur.package_root =~ "/packages/unified_iur"
    assert report.packages.live_ui.package_root =~ "/packages/live_ui"

    assert Enum.any?(
             report.general_spec_paths,
             &String.ends_with?(&1, ".spec/specs/architecture.spec.md")
           )
  end

  test "per-app review metadata includes the authored, canonical, and runtime traceability path" do
    assert {:ok, metadata} = Tooling.review_metadata("button")

    assert metadata.traceability.flow == [:unified_ui, :unified_iur, :live_ui]
    assert metadata.traceability.authored_dsl.package == :unified_ui
    assert metadata.traceability.canonical_iur.package == :unified_iur
    assert metadata.traceability.runtime_library.package == :live_ui
    assert metadata.traceability.authored_dsl.screen_module == UnifiedExamples.Button.Screen
    assert Enum.all?(metadata.traceability.general_spec_paths, &File.exists?/1)
    assert Enum.all?(metadata.traceability.governance_paths, &File.exists?/1)
  end
end
