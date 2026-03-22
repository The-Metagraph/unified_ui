defmodule TerminalUi.ToolingTest do
  use ExUnit.Case, async: true

  test "inspect workflows preview native canonical and mixed examples through one surface" do
    assert {:ok, native_preview} = TerminalUi.Inspect.preview(:native_styled_review)
    assert {:ok, canonical_preview} = TerminalUi.Inspect.preview(:canonical_styled_review)
    assert {:ok, mixed_preview} = TerminalUi.Inspect.preview(:styled_degradation_review)

    assert native_preview.metadata.category == :native
    assert native_preview.surface.runtime.theme == :high_contrast

    assert canonical_preview.metadata.category == :canonical
    assert canonical_preview.surface.runtime.theme == :high_contrast

    assert mixed_preview.metadata.category == :mixed
    assert mixed_preview.surface.parity.glyph_fallback_explicit?
    assert mixed_preview.surface.parity.degradation_bounded?
  end

  test "tooling validation workflows summarize examples runtime transport and capability behavior" do
    coverage = TerminalUi.Validate.example_coverage()
    renderer = TerminalUi.Validate.renderer_determinism()
    runtime = TerminalUi.Validate.runtime_behavior()
    transport = TerminalUi.Validate.transport_validation()
    capability = TerminalUi.Validate.capability_behavior()
    tooling = TerminalUi.Validate.tooling_surface()
    docs = TerminalUi.Validate.documentation_surface()
    report = TerminalUi.Validate.validation_report()

    assert coverage.status == :pass
    assert renderer.status == :pass
    assert runtime.status == :pass
    assert transport.status == :pass
    assert capability.status == :pass
    assert tooling.status == :pass
    assert docs.status == :pass
    assert report.example_coverage.status == :pass
    assert report.runtime_behavior.status == :pass
    assert report.transport_validation.status == :pass
    assert report.documentation_surface.status == :pass
    assert report.release_readiness.status == :pass

    assert {:ok, strict_report} = TerminalUi.Validate.validate(:strict)
    assert strict_report.release_readiness.failing_sections == []
    assert {:ok, strict_release} = TerminalUi.Validate.release_readiness(:strict)
    assert strict_release.status == :pass

    assert TerminalUi.Inspect in TerminalUi.Tooling.preview_surfaces()
    assert "mix terminal_ui.inspect" in TerminalUi.Tooling.mix_tasks()
    assert "mix terminal_ui.validate" in TerminalUi.Tooling.mix_tasks()

    assert Enum.any?(
             TerminalUi.Validate.evolution_rules(),
             &(&1.id == :terminal_ui_not_dsl_or_iur_owner)
           )
  end
end
