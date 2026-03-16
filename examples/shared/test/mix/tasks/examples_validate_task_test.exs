defmodule Mix.Tasks.ExamplesValidateTaskTest do
  use ExUnit.Case, async: false

  @moduletag timeout: 120_000

  import ExUnit.CaptureIO

  setup do
    Mix.Task.clear()
    :ok
  end

  test "mix examples.validate prints the validation summary" do
    output =
      capture_io(fn ->
        Mix.Tasks.Examples.Validate.run([])
      end)

    assert output =~ "Example suite validation"
    assert output =~ "valid?: true"
  end
end
