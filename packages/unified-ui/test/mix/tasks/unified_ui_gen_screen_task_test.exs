defmodule Mix.Tasks.UnifiedUi.Gen.ScreenTaskTest do
  use ExUnit.Case, async: true

  describe "run_with/2" do
    test "generates screen module, test file, and supervisor child spec" do
      root_path = unique_tmp_path()
      supervisor_file = create_supervisor_fixture!(root_path)
      output = fn line -> send(self(), {:output, line}) end

      module_dir = Path.join(root_path, "lib/demo/screens")
      test_dir = Path.join(root_path, "test/demo/screens")

      assert :ok =
               Mix.Tasks.UnifiedUi.Gen.Screen.run_with(
                 [
                   "Demo.CounterScreen",
                   "--path",
                   module_dir,
                   "--test-path",
                   test_dir,
                   "--supervisor-file",
                   supervisor_file
                 ],
                 output
               )

      module_file = Path.join(module_dir, "counter_screen.ex")
      test_file = Path.join(test_dir, "counter_screen_test.exs")

      assert File.exists?(module_file)
      assert File.exists?(test_file)

      assert File.read!(module_file) =~ "defmodule Demo.CounterScreen"
      assert File.read!(module_file) =~ ~s(button "Increment", on_click: :increment)
      assert File.read!(test_file) =~ "defmodule Demo.CounterScreenTest"
      assert File.read!(test_file) =~ "alias Demo.CounterScreen"
      assert File.read!(test_file) =~ "CounterScreen.init([])"

      supervisor_contents = File.read!(supervisor_file)

      assert supervisor_contents =~
               "{UnifiedUi.Agent.Server, module: Demo.CounterScreen, component_id: :counter_screen}"

      output_lines = collect_output()
      assert Enum.any?(output_lines, &String.starts_with?(&1, "Created screen: "))
      assert Enum.any?(output_lines, &String.starts_with?(&1, "Created test: "))
      assert Enum.any?(output_lines, &String.starts_with?(&1, "Updated supervisor: "))
    end

    test "respects --no-test and --no-supervisor" do
      root_path = unique_tmp_path()
      supervisor_file = create_supervisor_fixture!(root_path)

      module_file = Path.join(root_path, "lib/demo/minimal_screen.ex")

      assert :ok =
               Mix.Tasks.UnifiedUi.Gen.Screen.run_with(
                 [
                   "Demo.MinimalScreen",
                   "--path",
                   module_file,
                   "--supervisor-file",
                   supervisor_file,
                   "--no-test",
                   "--no-supervisor"
                 ],
                 fn _ -> :ok end
               )

      assert File.exists?(module_file)
      refute String.contains?(File.read!(supervisor_file), "Demo.MinimalScreen")
    end

    test "raises on unsupported options" do
      assert_raise Mix.Error, ~r/Unsupported options/, fn ->
        Mix.Tasks.UnifiedUi.Gen.Screen.run_with(["Demo.CounterScreen", "--nope"], fn _ -> :ok end)
      end
    end

    test "raises when file already exists without --force" do
      root_path = unique_tmp_path()
      supervisor_file = create_supervisor_fixture!(root_path)
      module_file = Path.join(root_path, "lib/demo/dupe_screen.ex")
      File.mkdir_p!(Path.dirname(module_file))
      File.write!(module_file, "defmodule Demo.DupeScreen do\nend\n")

      assert_raise Mix.Error, ~r/File already exists/, fn ->
        Mix.Tasks.UnifiedUi.Gen.Screen.run_with(
          ["Demo.DupeScreen", "--path", module_file, "--supervisor-file", supervisor_file],
          fn _ -> :ok end
        )
      end
    end

    test "overwrites files when --force is provided" do
      root_path = unique_tmp_path()
      supervisor_file = create_supervisor_fixture!(root_path)
      module_file = Path.join(root_path, "lib/demo/force_screen.ex")
      File.mkdir_p!(Path.dirname(module_file))
      File.write!(module_file, "old contents\n")

      assert :ok =
               Mix.Tasks.UnifiedUi.Gen.Screen.run_with(
                 [
                   "Demo.ForceScreen",
                   "--path",
                   module_file,
                   "--supervisor-file",
                   supervisor_file,
                   "--no-test",
                   "--no-supervisor",
                   "--force"
                 ],
                 fn _ -> :ok end
               )

      refute File.read!(module_file) == "old contents\n"
      assert File.read!(module_file) =~ "defmodule Demo.ForceScreen"
    end
  end

  defp unique_tmp_path do
    random = Base.encode16(:crypto.strong_rand_bytes(6), case: :lower)
    unique_name = "unified_ui_gen_screen_task_#{random}"
    root_path = Path.join(System.tmp_dir!(), unique_name)
    File.mkdir_p!(root_path)
    root_path
  end

  defp create_supervisor_fixture!(root_path) do
    supervisor_file = Path.join(root_path, "lib/demo/application.ex")

    File.mkdir_p!(Path.dirname(supervisor_file))

    File.write!(
      supervisor_file,
      """
      defmodule Demo.Application do
        use Application

        @impl true
        def start(_type, _args) do
          children = [
            {Registry, keys: :unique, name: Demo.Registry}
          ]

          Supervisor.start_link(children, strategy: :one_for_one, name: Demo.Supervisor)
        end
      end
      """
    )

    supervisor_file
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
