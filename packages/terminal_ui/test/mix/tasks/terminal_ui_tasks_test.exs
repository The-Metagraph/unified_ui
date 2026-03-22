defmodule Mix.Tasks.TerminalUiTasksTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  test "inspect task prints catalog and diagnostics-oriented maintainer output" do
    inspection =
      capture_io(fn ->
        Mix.Task.reenable("terminal_ui.inspect")
        Mix.Tasks.TerminalUi.Inspect.run(["native_styled_review", "--format", "diagnostics"])
      end)

    catalog =
      capture_io(fn ->
        Mix.Task.reenable("terminal_ui.inspect")
        Mix.Tasks.TerminalUi.Inspect.run(["--format", "catalog"])
      end)

    assert inspection =~ "native_styled_review"
    assert inspection =~ "transport_mappings"
    assert inspection =~ "capabilities"
    assert catalog =~ "native_foundational"
    assert catalog =~ "styled_degradation_review"
  end
end
