defmodule Mix.Tasks.UnifiedUi.FormatTaskTest do
  use ExUnit.Case, async: true

  defmodule FakeRunner do
    def run_task(task, args) do
      send(self(), {:run_task, task, args})
      :ok
    end
  end

  describe "run_with/2" do
    test "runs format task by default" do
      assert :ok = Mix.Tasks.UnifiedUi.Format.run_with([], FakeRunner)

      assert_received {:run_task, "format", []}
    end

    test "supports check mode and dry run flags" do
      assert :ok =
               Mix.Tasks.UnifiedUi.Format.run_with(
                 ["--check-formatted", "--dry-run"],
                 FakeRunner
               )

      assert_received {:run_task, "format", ["--check-formatted", "--dry-run"]}
    end

    test "supports --dot-formatter option" do
      assert :ok =
               Mix.Tasks.UnifiedUi.Format.run_with(
                 ["--dot-formatter", "config/.formatter.exs"],
                 FakeRunner
               )

      assert_received {:run_task, "format", ["--dot-formatter", "config/.formatter.exs"]}
    end

    test "passes through positional paths" do
      assert :ok =
               Mix.Tasks.UnifiedUi.Format.run_with(
                 ["--check-formatted", "lib/unified_ui.ex", "test/unified_ui_test.exs"],
                 FakeRunner
               )

      assert_received {:run_task, "format",
                       ["--check-formatted", "lib/unified_ui.ex", "test/unified_ui_test.exs"]}
    end

    test "raises on unsupported options" do
      assert_raise Mix.Error, ~r/Unsupported options/, fn ->
        Mix.Tasks.UnifiedUi.Format.run_with(["--nope"], FakeRunner)
      end
    end
  end
end
