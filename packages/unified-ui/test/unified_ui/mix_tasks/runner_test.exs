defmodule Mix.Tasks.UnifiedUi.RunnerFixture do
  use Mix.Task

  @impl true
  def run(args) do
    if pid = Process.whereis(:runner_test_process) do
      send(pid, {:fixture_task_called, args})
    end

    :ok
  end
end

defmodule UnifiedUi.MixTasks.RunnerTest do
  use ExUnit.Case, async: false

  alias UnifiedUi.MixTasks.Runner

  setup do
    Process.register(self(), :runner_test_process)

    on_exit(fn ->
      if Process.whereis(:runner_test_process) == self() do
        Process.unregister(:runner_test_process)
      end
    end)

    :ok
  end

  test "run_task/2 re-enables and runs a mix task" do
    assert :ok = Runner.run_task("unified_ui.runner_fixture", ["first"])
    assert_receive {:fixture_task_called, ["first"]}

    assert :ok = Runner.run_task("unified_ui.runner_fixture", ["second"])
    assert_receive {:fixture_task_called, ["second"]}
  end
end
