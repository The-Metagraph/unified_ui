defmodule Mix.Tasks.ExamplesTasksTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  @moduletag timeout: 180_000

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
    assert output =~ "Focused widget apps"
    assert output =~ "Aggregate review surfaces"
    assert output =~ "button"
    assert output =~ "overlay"
    assert output =~ "demo"
    assert output =~ "purpose=aggregate_demo"
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

    assert output =~ "directory: button"
    assert output =~ "url: http://127.0.0.1:4110/"
    assert output =~ "examples/button"
    assert output =~ "PORT=4110"
    assert output =~ "mix phx.server"
  end

  test "mix examples.launch exposes the aggregate demo through dry-run launch metadata" do
    output =
      capture_io(fn ->
        Mix.Tasks.Examples.Launch.run(["demo", "--dry-run", "--port", "4111"])
      end)

    assert output =~ "directory: demo"
    assert output =~ "url: http://127.0.0.1:4111/"
    assert output =~ "examples/demo"
    assert output =~ "mix phx.server"
  end

  test "mix examples.launch exposes a smoke-test workflow for browser-runnable example apps" do
    output =
      capture_io(fn ->
        Mix.Tasks.Examples.Launch.run(["button", "--smoke-test"])
      end)

    assert output =~ "Example launch smoke test"
    assert output =~ "directory: button"
    assert output =~ "status: 200"
    assert output =~ "launch_command:"
  end

  test "mix examples.launch exposes a smoke-test workflow for the aggregate demo" do
    output =
      capture_io(fn ->
        Mix.Tasks.Examples.Launch.run(["demo", "--smoke-test"])
      end)

    assert output =~ "Example launch smoke test"
    assert output =~ "directory: demo"
    assert output =~ "status: 200"
    assert output =~ "launch_command:"
  end

end
