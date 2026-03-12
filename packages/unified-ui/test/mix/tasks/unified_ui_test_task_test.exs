defmodule Mix.Tasks.UnifiedUi.TestTaskTest do
  use ExUnit.Case, async: true

  defmodule FakeRunner do
    def run_task(task, args) do
      send(self(), {:run_task, task, args})
      :ok
    end
  end

  describe "run_with/2" do
    test "runs test task by default" do
      assert :ok = Mix.Tasks.UnifiedUi.Test.run_with([], FakeRunner)

      assert_received {:run_task, "test", []}
      refute_received {:run_task, "credo", _}
    end

    test "passes --cover to test task" do
      assert :ok = Mix.Tasks.UnifiedUi.Test.run_with(["--cover"], FakeRunner)

      assert_received {:run_task, "test", ["--cover"]}
      refute_received {:run_task, "credo", _}
    end

    test "runs credo when strict mode is requested" do
      assert :ok = Mix.Tasks.UnifiedUi.Test.run_with(["--strict"], FakeRunner)

      assert_received {:run_task, "test", []}
      assert_received {:run_task, "credo", ["--strict"]}
    end

    test "supports pass-through test args" do
      args = ["--cover", "test/unified_ui/agent_test.exs"]
      assert :ok = Mix.Tasks.UnifiedUi.Test.run_with(args, FakeRunner)

      assert_received {:run_task, "test", ["--cover", "test/unified_ui/agent_test.exs"]}
    end

    test "raises on unsupported options" do
      assert_raise Mix.Error, ~r/Unsupported options/, fn ->
        Mix.Tasks.UnifiedUi.Test.run_with(["--nope"], FakeRunner)
      end
    end
  end
end
