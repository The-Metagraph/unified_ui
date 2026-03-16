defmodule Mix.Tasks.ExamplesReleaseTaskTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  setup do
    Mix.Task.clear()
    :ok
  end

  test "mix examples.release prints the maintainer workflow summary" do
    output =
      capture_io(fn ->
        Mix.Tasks.Examples.Release.run([])
      end)

    assert output =~ "Example suite maintainer workflow"
    assert output =~ "documentation_valid?: true"
    assert output =~ "mix examples.release --strict"
  end
end
