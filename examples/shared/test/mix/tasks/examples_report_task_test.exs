defmodule Mix.Tasks.ExamplesReportTaskTest do
  use ExUnit.Case, async: false

  @moduletag timeout: 120_000

  import ExUnit.CaptureIO

  setup do
    Mix.Task.clear()
    :ok
  end

  test "mix examples.report prints the review summary" do
    output =
      capture_io(fn ->
        Mix.Tasks.Examples.Report.run([])
      end)

    assert output =~ "Example suite review report"
    assert output =~ "catalog_total:"
    assert output =~ "validation_valid?: true"
  end
end
