defmodule Mix.Tasks.LiveUiTasksTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  test "preview task prints html and catalog output" do
    html =
      capture_io(fn ->
        Mix.Task.reenable("live_ui.preview")
        Mix.Tasks.LiveUi.Preview.run(["native_styled_profile", "--format", "html"])
      end)

    assert html =~ "data-live-ui-widget=\"box\""

    catalog =
      capture_io(fn ->
        Mix.Task.reenable("live_ui.preview")
        Mix.Tasks.LiveUi.Preview.run([])
      end)

    assert catalog =~ "native_display"
    assert catalog =~ "styled_continuity_compare"
  end

  test "demo task prints summary and html output" do
    summary =
      capture_io(fn ->
        Mix.Task.reenable("live_ui.demo")
        Mix.Tasks.LiveUi.Demo.run([])
      end)

    assert summary =~ "LiveUi demo summary"
    assert summary =~ "view: home"

    html =
      capture_io(fn ->
        Mix.Task.reenable("live_ui.demo")
        Mix.Tasks.LiveUi.Demo.run(["native_styled_profile", "--format", "html"])
      end)

    assert html =~ "Native Styled Profile"
    assert html =~ "data-live-ui-runtime=\"screen\""
  end

  test "inspect and export tasks print comparison-oriented maintainer output" do
    inspection =
      capture_io(fn ->
        Mix.Task.reenable("live_ui.inspect")
        Mix.Tasks.LiveUi.Inspect.run(["native_styled_operations", "--format", "comparison"])
      end)

    assert inspection =~ "canonical_styled_operations"
    assert inspection =~ "widgets_aligned?"

    export =
      capture_io(fn ->
        Mix.Task.reenable("live_ui.export")
        Mix.Tasks.LiveUi.Export.run(["native_styled_profile", "--format", "metadata"])
      end)

    assert export =~ "review_artifact"
    assert export =~ "native_styled_profile"
  end
end
