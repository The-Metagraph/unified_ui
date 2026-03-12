defmodule Mix.Tasks.UnifiedUi.TasksHelpTest do
  use ExUnit.Case, async: true

  @task_modules [
    Mix.Tasks.UnifiedUi.New,
    Mix.Tasks.UnifiedUi.Gen.Screen,
    Mix.Tasks.UnifiedUi.Gen.Widget,
    Mix.Tasks.UnifiedUi.Format,
    Mix.Tasks.UnifiedUi.Preview,
    Mix.Tasks.UnifiedUi.Test,
    Mix.Tasks.UnifiedUi.Stats,
    Mix.Tasks.UnifiedUi.Bench,
    Mix.Tasks.UnifiedUi.Perf.Check
  ]

  test "all UnifiedUi tasks have shortdoc and moduledoc" do
    Enum.each(@task_modules, fn module ->
      assert Code.ensure_loaded?(module)

      shortdoc =
        module.__info__(:attributes)
        |> Keyword.get(:shortdoc)

      assert is_list(shortdoc)
      assert shortdoc != []
      assert Enum.all?(shortdoc, &is_binary/1)

      assert {:docs_v1, _, _, _, moduledoc, _, _} = Code.fetch_docs(module)
      refute moduledoc == :none
    end)
  end
end
