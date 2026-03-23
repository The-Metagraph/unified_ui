defmodule TerminalUi.PhaseSixIntegrationTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  test "maintained examples and inspect workflows expose native canonical and mixed review paths through one tooling surface" do
    assert {:ok, native_preview} = TerminalUi.Tooling.preview_example(:native_styled_review)
    assert {:ok, canonical_preview} = TerminalUi.Tooling.preview_example(:canonical_styled_review)
    assert {:ok, mixed_preview} = TerminalUi.Tooling.preview_example(:styled_degradation_review)

    assert native_preview.metadata.category == :native
    assert native_preview.surface.runtime.source_kind == :native
    assert native_preview.surface.runtime.theme == :high_contrast

    assert canonical_preview.metadata.category == :canonical
    assert canonical_preview.surface.runtime.source_kind == :canonical
    assert canonical_preview.surface.runtime.theme == :high_contrast

    assert mixed_preview.metadata.category == :mixed
    assert mixed_preview.surface.parity.glyph_fallback_explicit?
    assert mixed_preview.surface.parity.degradation_bounded?

    reference = TerminalUi.Reference.package_reference()

    assert :styled_degradation_review in reference.examples.mixed_ids
    assert TerminalUi.Inspect in reference.tooling.preview_surfaces
  end

  test "inspect and validate tasks provide one repeatable maintainer command path" do
    inspect_output =
      capture_io(fn ->
        Mix.Task.reenable("terminal_ui.inspect")
        Mix.Tasks.TerminalUi.Inspect.run(["styled_degradation_review", "--format", "comparison"])
      end)

    validate_output =
      capture_io(fn ->
        Mix.Task.reenable("terminal_ui.validate")
        Mix.Tasks.TerminalUi.Validate.run(["--format", "summary"])
      end)

    assert inspect_output =~ "styled_degradation_review"
    assert inspect_output =~ "glyph_fallback_explicit?"
    assert validate_output =~ "TerminalUi validation summary"
    assert validate_output =~ "documentation surface passing?: true"
    assert validate_output =~ "release ready?: true"
  end

  test "strict validation keeps examples tooling docs and evolution gates release-ready" do
    report = TerminalUi.Validate.validation_report()

    assert report.example_coverage.status == :pass
    assert report.runtime_behavior.status == :pass
    assert report.transport_validation.status == :pass
    assert report.capability_behavior.status == :pass
    assert report.tooling_surface.status == :pass
    assert report.documentation_surface.status == :pass
    assert report.release_readiness.status == :pass
    assert Enum.all?(report.release_readiness.gates, &(&1.status == :pass))

    assert Enum.any?(
             report.release_readiness.evolution_rules,
             &(&1.id == :terminal_ui_not_dsl_or_iur_owner)
           )

    strict_output =
      capture_io(fn ->
        Mix.Task.reenable("terminal_ui.validate")
        Mix.Tasks.TerminalUi.Validate.run(["--strict"])
      end)

    assert strict_output =~ "release ready?: true"
    assert "mix terminal_ui.inspect" in TerminalUi.Tooling.mix_tasks()
    assert "mix terminal_ui.validate" in TerminalUi.Tooling.mix_tasks()
  end
end
