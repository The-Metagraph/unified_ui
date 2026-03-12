defmodule Mix.Tasks.UnifiedUi.BenchTaskTest do
  use ExUnit.Case, async: true

  defmodule FakeRunner do
    def run_task(task, args) do
      send(self(), {:run_task, task, args})
      :ok
    end
  end

  describe "run_with/2" do
    test "runs baseline benchmark script by default" do
      assert :ok = Mix.Tasks.UnifiedUi.Bench.run_with([], FakeRunner)

      assert_received {:run_task, "run", ["benchmarks/phase5_baseline.exs"]}
    end

    test "passes quick flag through to benchmark script" do
      assert :ok = Mix.Tasks.UnifiedUi.Bench.run_with(["--quick"], FakeRunner)

      assert_received {:run_task, "run", ["benchmarks/phase5_baseline.exs", "--quick"]}
    end

    test "raises on unsupported options" do
      assert_raise Mix.Error, ~r/Unsupported options/, fn ->
        Mix.Tasks.UnifiedUi.Bench.run_with(["--nope"], FakeRunner)
      end
    end
  end
end
