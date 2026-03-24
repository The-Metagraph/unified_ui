defmodule DesktopUi.MixTasksTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  @tasks ["app.start", "desktop_ui.inspect", "desktop_ui.validate"]

  setup do
    Enum.each(@tasks, &Mix.Task.reenable/1)
    :ok
  end

  test "inspect task prints catalog and example inspection output" do
    catalog_output =
      capture_io(fn ->
        run_task("desktop_ui.inspect", ["--format", "catalog"])
      end)

    report_output =
      capture_io(fn ->
        run_task("desktop_ui.inspect", ["styled_continuity_review", "--format", "comparison"])
      end)

    assert catalog_output =~ "native_styled_review"
    assert report_output =~ "styled_continuity_review"
    assert report_output =~ "parity"
  end

  test "validate task prints summary and supports strict mode" do
    summary_output =
      capture_io(fn ->
        run_task("desktop_ui.validate", [])
      end)

    strict_output =
      capture_io(fn ->
        run_task("desktop_ui.validate", ["--strict"])
      end)

    assert summary_output =~ "DesktopUi validation summary"
    assert strict_output =~ "release ready?: true"
  end

  defp run_task(task, args) do
    Mix.Task.reenable("app.start")
    Mix.Task.reenable(task)
    Mix.Task.run(task, args)
  end
end
