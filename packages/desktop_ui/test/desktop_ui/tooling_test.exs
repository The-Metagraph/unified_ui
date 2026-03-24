defmodule DesktopUi.ToolingTest do
  use ExUnit.Case, async: true

  test "inspect workflows preview native, canonical, and mixed examples through one surface" do
    assert {:ok, native_preview} = DesktopUi.Inspect.preview(:native_styled_review)
    assert {:ok, canonical_preview} = DesktopUi.Inspect.preview(:canonical_styled_review)
    assert {:ok, mixed_preview} = DesktopUi.Inspect.preview(:styled_continuity_review)
    assert {:ok, rendered_metadata} = DesktopUi.Inspect.render("native_styled_review", :metadata)

    assert {:ok, rendered_diagnostics} =
             DesktopUi.Inspect.render("styled_continuity_review", :diagnostics)

    assert native_preview.metadata.category == :native
    assert native_preview.surface.runtime.theme == :high_contrast
    assert canonical_preview.metadata.category == :canonical
    assert canonical_preview.surface.runtime.theme == :high_contrast
    assert mixed_preview.metadata.category == :mixed
    assert mixed_preview.surface.parity.style_resolution_match?
    assert rendered_metadata =~ ":native_styled_review"
    assert rendered_diagnostics =~ "tooling_workflows"
  end

  test "validation workflows summarize coverage, runtime behavior, transport, artifacts, and release readiness" do
    coverage = DesktopUi.Validate.example_coverage()
    runtime = DesktopUi.Validate.runtime_behavior()
    transport = DesktopUi.Validate.transport_validation()
    artifacts = DesktopUi.Validate.artifact_validation()
    tooling = DesktopUi.Validate.tooling_surface()
    docs = DesktopUi.Validate.documentation_surface()
    traceability = DesktopUi.Validate.traceability_alignment()
    validation_report = DesktopUi.Validate.validation_report()
    validation_summary = DesktopUi.Validate.validation_summary(validation_report)

    assert coverage.status == :pass
    assert runtime.status == :pass
    assert transport.status == :pass
    assert artifacts.status == :pass
    assert tooling.status == :pass
    assert docs.status == :pass
    assert traceability.status == :pass

    assert {:ok, summary_report} = DesktopUi.Validate.release_readiness(:summary)
    assert {:ok, strict_report} = DesktopUi.Validate.release_readiness(:strict)

    assert summary_report.status == :pass
    assert strict_report.status == :pass
    assert summary_report.findings == []
    assert strict_report.findings == []
    assert Enum.all?(summary_report.gates, &(&1.status == :pass))
    assert validation_report.release_readiness.status == :pass
    assert validation_summary =~ "DesktopUi validation summary"
    assert validation_summary =~ "release ready?: true"
    assert validation_report.documentation_surface.status == :pass
    assert validation_report.traceability_alignment.status == :pass
    assert "mix spec.traceability.generate desktop_ui" in DesktopUi.Tooling.mix_tasks()

    assert Enum.any?(
             DesktopUi.Validate.evolution_rules(),
             &(&1.id == :desktop_ui_not_dsl_or_iur_owner)
           )
  end
end
