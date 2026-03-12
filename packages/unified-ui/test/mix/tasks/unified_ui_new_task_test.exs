defmodule Mix.Tasks.UnifiedUi.NewTaskTest do
  use ExUnit.Case, async: true

  describe "run_with/2" do
    test "generates a new project scaffold with example screen" do
      root_path = unique_tmp_path()
      project_path = Path.join(root_path, "demo_app")
      output = fn line -> send(self(), {:output, line}) end

      assert :ok =
               Mix.Tasks.UnifiedUi.New.run_with(
                 ["demo_app", "--path", project_path],
                 output
               )

      assert File.exists?(Path.join(project_path, "mix.exs"))
      assert File.exists?(Path.join(project_path, "config/config.exs"))
      assert File.exists?(Path.join(project_path, ".formatter.exs"))
      assert File.exists?(Path.join(project_path, "README.md"))
      assert File.exists?(Path.join(project_path, "lib/demo_app/application.ex"))
      assert File.exists?(Path.join(project_path, "lib/demo_app/screens/home_screen.ex"))
      assert File.exists?(Path.join(project_path, "test/test_helper.exs"))
      assert File.exists?(Path.join(project_path, "test/demo_app/screens/home_screen_test.exs"))

      mix_exs = File.read!(Path.join(project_path, "mix.exs"))
      screen = File.read!(Path.join(project_path, "lib/demo_app/screens/home_screen.ex"))
      app = File.read!(Path.join(project_path, "lib/demo_app/application.ex"))

      assert mix_exs =~ "defmodule DemoApp.MixProject"
      assert mix_exs =~ "app: :demo_app"
      assert screen =~ "defmodule DemoApp.Screens.HomeScreen"
      assert screen =~ ~s(button "Increment", on_click: :increment)
      assert app =~ "DynamicSupervisor"

      output_lines = collect_output()
      assert Enum.any?(output_lines, &(&1 == "Created mix.exs"))
      assert Enum.any?(output_lines, &String.starts_with?(&1, "Created project: "))
    end

    test "raises on invalid app name" do
      assert_raise Mix.Error, ~r/Invalid app name/, fn ->
        Mix.Tasks.UnifiedUi.New.run_with(["DemoApp"], fn _ -> :ok end)
      end
    end

    test "raises on unsupported options" do
      assert_raise Mix.Error, ~r/Unsupported options/, fn ->
        Mix.Tasks.UnifiedUi.New.run_with(["demo_app", "--nope"], fn _ -> :ok end)
      end
    end

    test "raises when target path exists without --force" do
      root_path = unique_tmp_path()
      project_path = Path.join(root_path, "demo_app")
      File.mkdir_p!(project_path)

      assert_raise Mix.Error, ~r/Target path already exists/, fn ->
        Mix.Tasks.UnifiedUi.New.run_with(["demo_app", "--path", project_path], fn _ -> :ok end)
      end
    end

    test "overwrites scaffold files with --force" do
      root_path = unique_tmp_path()
      project_path = Path.join(root_path, "demo_app")
      File.mkdir_p!(project_path)
      File.write!(Path.join(project_path, "mix.exs"), "old contents\n")

      assert :ok =
               Mix.Tasks.UnifiedUi.New.run_with(
                 ["demo_app", "--path", project_path, "--force"],
                 fn _ -> :ok end
               )

      refute File.read!(Path.join(project_path, "mix.exs")) == "old contents\n"
      assert File.read!(Path.join(project_path, "mix.exs")) =~ "defmodule DemoApp.MixProject"
    end
  end

  defp unique_tmp_path do
    random = Base.encode16(:crypto.strong_rand_bytes(6), case: :lower)
    root_path = Path.join(System.tmp_dir!(), "unified_ui_new_task_#{random}")
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
