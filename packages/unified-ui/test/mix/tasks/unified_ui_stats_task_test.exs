defmodule Mix.Tasks.UnifiedUi.StatsTaskTest do
  use ExUnit.Case, async: true

  describe "run_with/2" do
    test "reports statistics for a project path" do
      root_path = unique_tmp_path()
      create_project_fixture!(root_path)
      collector = fn line -> send(self(), {:output, line}) end

      assert :ok = Mix.Tasks.UnifiedUi.Stats.run_with(["--path", root_path], collector)

      assert collect_output() == [
               "UnifiedUi Project Statistics",
               "Path: #{Path.expand(root_path)}",
               "Library modules: 3",
               "Library files: 3",
               "Test files: 1",
               "Mix tasks: 1",
               "Guide files: 1",
               "Elixir LOC (lib + test): 4"
             ]
    end

    test "uses current directory when no path is provided" do
      collector = fn line -> send(self(), {:output, line}) end
      cwd = Path.expand(File.cwd!())

      assert :ok = Mix.Tasks.UnifiedUi.Stats.run_with([], collector)
      assert Enum.at(collect_output(), 1) == "Path: #{cwd}"
    end

    test "raises on unsupported options" do
      assert_raise Mix.Error, ~r/Unsupported options/, fn ->
        Mix.Tasks.UnifiedUi.Stats.run_with(["--nope"], fn _ -> :ok end)
      end
    end
  end

  defp unique_tmp_path do
    unique_name = "unified_ui_stats_task_#{System.unique_integer([:positive])}"
    root_path = Path.join(System.tmp_dir!(), unique_name)
    File.mkdir_p!(root_path)
    root_path
  end

  defp create_project_fixture!(root_path) do
    create_file!(root_path, "lib/unified_ui.ex", "defmodule Fixture.UnifiedUi, do: :ok\n")
    create_file!(root_path, "lib/feature.ex", "defmodule Fixture.Feature, do: :ok\n")

    create_file!(
      root_path,
      "lib/mix/tasks/unified_ui.sample.ex",
      "defmodule Mix.Tasks.UnifiedUi.Sample, do: :ok\n"
    )

    create_file!(root_path, "test/feature_test.exs", "defmodule Fixture.FeatureTest, do: :ok\n")
    create_file!(root_path, "guides/intro.md", "# Intro\n")
  end

  defp create_file!(root_path, relative_path, contents) do
    file_path = Path.join(root_path, relative_path)
    file_path |> Path.dirname() |> File.mkdir_p!()
    File.write!(file_path, contents)
  end

  defp collect_output(lines \\ []) do
    receive do
      {:output, line} ->
        collect_output([line | lines])
    after
      0 ->
        Enum.reverse(lines)
    end
  end
end
