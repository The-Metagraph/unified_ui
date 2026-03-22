defmodule WebUi.ToolingTest do
  use ExUnit.Case, async: true

  test "inspect workflows preview native, canonical, and mixed examples through one surface" do
    assert {:ok, native_preview} = WebUi.Inspect.preview(:native_styling)
    assert {:ok, canonical_preview} = WebUi.Inspect.preview(:canonical_styling)
    assert {:ok, mixed_preview} = WebUi.Inspect.preview(:styling_continuity)

    assert native_preview.metadata.category == :native
    assert native_preview.surface.runtime.theme == :midnight

    assert canonical_preview.metadata.category == :canonical
    assert canonical_preview.surface.runtime.theme == :midnight

    assert mixed_preview.metadata.category == :mixed
    assert mixed_preview.surface.continuity.validation.status == :pass
  end

  test "export workflows use stable artifact names from example metadata" do
    assert {:ok, artifact} = WebUi.Export.artifact(:styling_continuity)

    assert artifact.artifact_names.preview == "web_ui.examples.styling_continuity.preview"
    assert artifact.artifact_names.export == "web_ui.examples.styling_continuity.export"
    assert artifact.metadata.workflow == :styling
    assert artifact.payload.continuity.validation.status == :pass
  end

  test "validation workflows summarize coverage, runtime behavior, and release readiness" do
    coverage = WebUi.Validate.example_coverage()
    runtime = WebUi.Validate.runtime_behavior()
    tooling = WebUi.Validate.tooling_surface()

    assert coverage.status == :pass
    assert runtime.status == :pass
    assert tooling.status == :pass

    assert {:ok, summary_report} = WebUi.Validate.release_readiness(:summary)
    assert {:ok, strict_report} = WebUi.Validate.release_readiness(:strict)

    assert summary_report.status == :pass
    assert strict_report.status == :pass
    assert summary_report.findings == []
    assert strict_report.findings == []
  end
end
