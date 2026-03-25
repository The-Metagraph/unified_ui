defmodule DesktopUi.MixTasksTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  @tasks ["app.start", "desktop_ui.inspect", "desktop_ui.run", "desktop_ui.validate"]

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

    host_output =
      capture_io(fn ->
        run_task("desktop_ui.inspect", ["native_foundational", "--format", "host"])
      end)

    assert catalog_output =~ "native_styled_review"
    assert report_output =~ "styled_continuity_review"
    assert report_output =~ "parity"
    assert host_output =~ ":native_foundational"
  end

  test "run task prints catalog and host execution output" do
    catalog_output =
      capture_io(fn ->
        run_task("desktop_ui.run", ["--format", "catalog"])
      end)

    summary_output =
      capture_io(fn ->
        run_task("desktop_ui.run", ["native_foundational", "--format", "summary"])
      end)

    assert catalog_output =~ "runnable_examples"
    assert summary_output =~ "DesktopUi host execution summary"
    assert summary_output =~ "presented frame?: true"
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
    assert summary_output =~ "host execution surface passing?: true"
    assert strict_output =~ "release ready?: true"
  end

  defp run_task(task, args) do
    Mix.Task.reenable("app.start")
    Mix.Task.reenable(task)
    Mix.Task.run(task, args)
  end
end
