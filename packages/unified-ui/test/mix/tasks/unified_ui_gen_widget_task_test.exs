defmodule Mix.Tasks.UnifiedUi.Gen.WidgetTaskTest do
  use ExUnit.Case, async: true

  describe "run_with/2" do
    test "generates widget module and test file" do
      root_path = unique_tmp_path()
      output = fn line -> send(self(), {:output, line}) end

      module_dir = Path.join(root_path, "lib/demo/widgets")
      test_dir = Path.join(root_path, "test/demo/widgets")

      assert :ok =
               Mix.Tasks.UnifiedUi.Gen.Widget.run_with(
                 ["Demo.Widgets.StatusBadge", "--path", module_dir, "--test-path", test_dir],
                 output
               )

      module_file = Path.join(module_dir, "status_badge.ex")
      test_file = Path.join(test_dir, "status_badge_test.exs")

      assert File.exists?(module_file)
      assert File.exists?(test_file)

      assert File.read!(module_file) =~ "defmodule Demo.Widgets.StatusBadge"

      assert File.read!(module_file) =~
               "defimpl UnifiedIUR.Element, for: Demo.Widgets.StatusBadge"

      assert File.read!(module_file) =~ "type: :status_badge"

      assert File.read!(test_file) =~ "defmodule Demo.Widgets.StatusBadgeTest"
      assert File.read!(test_file) =~ "alias Demo.Widgets.StatusBadge"
      assert File.read!(test_file) =~ "UnifiedIUR.Element.metadata(widget)"

      output_lines = collect_output()
      assert Enum.any?(output_lines, &String.starts_with?(&1, "Created widget: "))
      assert Enum.any?(output_lines, &String.starts_with?(&1, "Created test: "))
    end

    test "respects --no-test option" do
      root_path = unique_tmp_path()
      module_file = Path.join(root_path, "lib/demo/widgets/simple_badge.ex")

      assert :ok =
               Mix.Tasks.UnifiedUi.Gen.Widget.run_with(
                 ["Demo.Widgets.SimpleBadge", "--path", module_file, "--no-test"],
                 fn _ -> :ok end
               )

      assert File.exists?(module_file)
      refute File.exists?(Path.join(root_path, "test/demo/widgets/simple_badge_test.exs"))
    end

    test "raises on unsupported options" do
      assert_raise Mix.Error, ~r/Unsupported options/, fn ->
        Mix.Tasks.UnifiedUi.Gen.Widget.run_with(
          ["Demo.Widgets.StatusBadge", "--nope"],
          fn _ -> :ok end
        )
      end
    end

    test "raises when file already exists without --force" do
      root_path = unique_tmp_path()
      module_file = Path.join(root_path, "lib/demo/widgets/dupe_badge.ex")
      File.mkdir_p!(Path.dirname(module_file))
      File.write!(module_file, "defmodule Demo.Widgets.DupeBadge do\nend\n")

      assert_raise Mix.Error, ~r/File already exists/, fn ->
        Mix.Tasks.UnifiedUi.Gen.Widget.run_with(
          ["Demo.Widgets.DupeBadge", "--path", module_file, "--no-test"],
          fn _ -> :ok end
        )
      end
    end

    test "overwrites files when --force is provided" do
      root_path = unique_tmp_path()
      module_file = Path.join(root_path, "lib/demo/widgets/force_badge.ex")
      File.mkdir_p!(Path.dirname(module_file))
      File.write!(module_file, "old contents\n")

      assert :ok =
               Mix.Tasks.UnifiedUi.Gen.Widget.run_with(
                 ["Demo.Widgets.ForceBadge", "--path", module_file, "--no-test", "--force"],
                 fn _ -> :ok end
               )

      refute File.read!(module_file) == "old contents\n"
      assert File.read!(module_file) =~ "defmodule Demo.Widgets.ForceBadge"
    end
  end

  defp unique_tmp_path do
    random = Base.encode16(:crypto.strong_rand_bytes(6), case: :lower)
    root_path = Path.join(System.tmp_dir!(), "unified_ui_gen_widget_task_#{random}")
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
