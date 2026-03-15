defmodule LiveUi.Phase6IntegrationTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  test "maintained examples cover native canonical and mixed review workflows through one tooling surface" do
    assert {:ok, native_preview} = LiveUi.Tooling.preview_example(:native_styled_profile)
    assert {:ok, canonical_preview} = LiveUi.Tooling.preview_example(:canonical_styled_operations)
    assert {:ok, mixed_preview} = LiveUi.Tooling.preview_example(:styled_continuity_compare)

    assert native_preview.example.path == :native
    assert canonical_preview.example.path == :canonical
    assert mixed_preview.example.path == :mixed

    assert native_preview.result.html =~ "data-live-ui-widget=\"box\""
    assert canonical_preview.result.html =~ "data-live-ui-widget=\"overlay-surface\""
    assert mixed_preview.result.operations.continuity.widgets_aligned?
    assert mixed_preview.result.boundary.runtime_action.runtime_event == "rename"
  end

  test "preview inspect export and validate tasks provide one repeatable maintainer command path" do
    preview =
      capture_io(fn ->
        Mix.Task.reenable("live_ui.preview")
        Mix.Tasks.LiveUi.Preview.run(["canonical_styled_profile", "--format", "html"])
      end)

    inspect_output =
      capture_io(fn ->
        Mix.Task.reenable("live_ui.inspect")
        Mix.Tasks.LiveUi.Inspect.run(["native_styled_operations", "--format", "comparison"])
      end)

    export_output =
      capture_io(fn ->
        Mix.Task.reenable("live_ui.export")
        Mix.Tasks.LiveUi.Export.run(["styled_continuity_compare", "--format", "diagnostics"])
      end)

    validate_output =
      capture_io(fn ->
        Mix.Task.reenable("live_ui.validate")
        Mix.Tasks.LiveUi.Validate.run(["--format", "summary"])
      end)

    assert preview =~ "data-live-ui-widget=\"box\""
    assert inspect_output =~ "native_styled_operations"
    assert inspect_output =~ "canonical_styled_operations"
    assert export_output =~ "styled_continuity_compare"
    assert export_output =~ "runtime_action"
    assert validate_output =~ "LiveUi validation summary"
    assert validate_output =~ "release ready?: true"
  end

  test "strict validation keeps example health continuity transport and documentation release-ready" do
    report = LiveUi.Tooling.validation_report()

    assert report.example_health.all_passing?
    assert report.example_coverage.complete?
    assert report.continuity.aligned?
    assert report.transport.sound?
    assert report.runtime_authority.server_authoritative?
    assert report.documentation_surface.complete?
    assert report.release_readiness.ready?

    strict_output =
      capture_io(fn ->
        Mix.Task.reenable("live_ui.validate")
        Mix.Tasks.LiveUi.Validate.run(["--strict"])
      end)

    assert strict_output =~ "release ready?: true"
    assert "mix live_ui.validate" in LiveUi.Tooling.mix_tasks()
  end
end
