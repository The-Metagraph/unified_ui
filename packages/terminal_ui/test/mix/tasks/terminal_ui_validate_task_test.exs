defmodule Mix.Tasks.TerminalUiValidateTaskTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  test "validate task prints summary and report output" do
    summary =
      capture_io(fn ->
        Mix.Task.reenable("terminal_ui.validate")
        Mix.Tasks.TerminalUi.Validate.run([])
      end)

    report =
      capture_io(fn ->
        Mix.Task.reenable("terminal_ui.validate")
        Mix.Tasks.TerminalUi.Validate.run(["--format", "report"])
      end)

    assert summary =~ "TerminalUi validation summary"
    assert summary =~ "renderer deterministic?: true"
    assert summary =~ "release ready?: true"
    assert report =~ "example_coverage"
    assert report =~ "release_readiness"
    assert report =~ "transport_validation"
  end

  test "validate task supports strict release-readiness mode" do
    strict_output =
      capture_io(fn ->
        Mix.Task.reenable("terminal_ui.validate")
        Mix.Tasks.TerminalUi.Validate.run(["--strict"])
      end)

    assert strict_output =~ "release ready?: true"
  end
end
