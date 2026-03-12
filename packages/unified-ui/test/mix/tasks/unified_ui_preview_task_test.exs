defmodule Mix.Tasks.UnifiedUi.PreviewTaskTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.{Layouts, Widgets}

  defmodule PreviewFixtureScreen do
    def init(_opts), do: %{count: 3}

    def view(state) do
      %Layouts.VBox{
        id: :root,
        children: [
          %Widgets.Text{id: :title, content: "Count: #{state.count}"}
        ]
      }
    end
  end

  defmodule NoViewFixture do
    def init(_opts), do: %{}
  end

  describe "run_with/2" do
    test "renders terminal preview by default" do
      module_name = module_name(PreviewFixtureScreen)
      output = fn line -> send(self(), {:output, line}) end

      assert :ok = Mix.Tasks.UnifiedUi.Preview.run_with([module_name], output)

      lines = collect_output()
      assert Enum.any?(lines, &(&1 == "Preview module: #{module_name}"))
      assert Enum.any?(lines, &(&1 == "Rendered terminal preview"))
    end

    test "renders web preview and writes html output" do
      module_name = module_name(PreviewFixtureScreen)
      root_path = unique_tmp_path()
      web_output = Path.join(root_path, "preview.html")

      assert :ok =
               Mix.Tasks.UnifiedUi.Preview.run_with(
                 [module_name, "--platform", "web", "--web-output", web_output],
                 fn _ -> :ok end
               )

      assert File.exists?(web_output)
      assert File.read!(web_output) =~ "<"
    end

    test "renders all platform previews" do
      module_name = module_name(PreviewFixtureScreen)
      output = fn line -> send(self(), {:output, line}) end

      assert :ok =
               Mix.Tasks.UnifiedUi.Preview.run_with(
                 [module_name, "--platform", "all"],
                 output
               )

      lines = collect_output()
      assert Enum.any?(lines, &(&1 == "Rendered terminal preview"))
      assert Enum.any?(lines, &(&1 == "Rendered desktop preview"))
      assert Enum.any?(lines, &(&1 == "Rendered web preview"))
    end

    test "raises for invalid platform option" do
      module_name = module_name(PreviewFixtureScreen)

      assert_raise Mix.Error, ~r/Invalid --platform value/, fn ->
        Mix.Tasks.UnifiedUi.Preview.run_with([module_name, "--platform", "mobile"], fn _ ->
          :ok
        end)
      end
    end

    test "raises for modules without view/1" do
      module_name = module_name(NoViewFixture)

      assert_raise Mix.Error, ~r/must export view\/1/, fn ->
        Mix.Tasks.UnifiedUi.Preview.run_with([module_name], fn _ -> :ok end)
      end
    end
  end

  defp module_name(module) do
    module
    |> Atom.to_string()
    |> String.trim_leading("Elixir.")
  end

  defp unique_tmp_path do
    random = Base.encode16(:crypto.strong_rand_bytes(6), case: :lower)
    root_path = Path.join(System.tmp_dir!(), "unified_ui_preview_task_#{random}")
    File.mkdir_p!(root_path)
    root_path
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
