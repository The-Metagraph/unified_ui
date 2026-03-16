defmodule Mix.Tasks.ExamplesTasksTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  setup do
    Mix.Task.clear()
    :ok
  end

  test "mix examples.list prints the suite catalog" do
    output =
      capture_io(fn ->
        Mix.Tasks.Examples.List.run([])
      end)

    assert output =~ "Example suite catalog"
    assert output =~ "button"
    assert output =~ "overlay"
  end

  test "mix examples.preview routes preview output for representative apps" do
    output =
      capture_io(fn ->
        Mix.Tasks.Examples.Preview.run(["button", "--format", "metadata"])
      end)

    assert output =~ "widget: :button"
    assert output =~ "family: :content"
  end

  test "mix examples.run exposes a dry-run command for independent app execution" do
    output =
      capture_io(fn ->
        Mix.Tasks.Examples.Run.run(["overlay", "--dry-run"])
      end)

    assert output =~ "examples/overlay"
    assert output =~ "mix test"
  end

  test "mix examples.launch exposes a dry-run command for browser-runnable example apps" do
    output =
      capture_io(fn ->
        Mix.Tasks.Examples.Launch.run(["button", "--dry-run", "--port", "4110"])
      end)

    assert output =~ "examples/button"
    assert output =~ "PORT=4110"
    assert output =~ "mix phx.server"
  end
end
