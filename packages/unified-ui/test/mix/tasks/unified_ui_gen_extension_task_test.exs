defmodule Mix.Tasks.UnifiedUi.Gen.ExtensionTaskTest do
  use ExUnit.Case, async: true

  describe "run_with/2" do
    test "generates extension module and test file" do
      root_path = unique_tmp_path()
      output = fn line -> send(self(), {:output, line}) end

      module_dir = Path.join(root_path, "lib/demo/extensions")
      test_dir = Path.join(root_path, "test/demo/extensions")

      assert :ok =
               Mix.Tasks.UnifiedUi.Gen.Extension.run_with(
                 ["Demo.Extensions.Observability", "--path", module_dir, "--test-path", test_dir],
                 output
               )

      module_file = Path.join(module_dir, "observability.ex")
      test_file = Path.join(test_dir, "observability_test.exs")

      assert File.exists?(module_file)
      assert File.exists?(test_file)

      assert File.read!(module_file) =~ "defmodule Demo.Extensions.Observability"
      assert File.read!(module_file) =~ "defmodule Widgets.StatusBadge"
      assert File.read!(module_file) =~ "defmodule Renderers.Terminal"

      assert File.read!(module_file) =~
               "defimpl UnifiedIUR.Element, for: Demo.Extensions.Observability.Widgets.StatusBadge"

      assert File.read!(module_file) =~ "type: :observability_status_badge"

      assert File.read!(test_file) =~ "defmodule Demo.Extensions.ObservabilityTest"
      assert File.read!(test_file) =~ "alias Demo.Extensions.Observability"
      assert File.read!(test_file) =~ "Observability.components()"

      output_lines = collect_output()
      assert Enum.any?(output_lines, &String.starts_with?(&1, "Created extension: "))
      assert Enum.any?(output_lines, &String.starts_with?(&1, "Created test: "))
    end

    test "respects --no-test option" do
      root_path = unique_tmp_path()
      module_file = Path.join(root_path, "lib/demo/extensions/metrics.ex")

      assert :ok =
               Mix.Tasks.UnifiedUi.Gen.Extension.run_with(
                 ["Demo.Extensions.Metrics", "--path", module_file, "--no-test"],
                 fn _ -> :ok end
               )

      assert File.exists?(module_file)
      refute File.exists?(Path.join(root_path, "test/demo/extensions/metrics_test.exs"))
    end

    test "raises on unsupported options" do
      assert_raise Mix.Error, ~r/Unsupported options/, fn ->
        Mix.Tasks.UnifiedUi.Gen.Extension.run_with(
          ["Demo.Extensions.Observability", "--nope"],
          fn _ -> :ok end
        )
      end
    end

    test "raises when file already exists without --force" do
      root_path = unique_tmp_path()
      module_file = Path.join(root_path, "lib/demo/extensions/dupe.ex")
      File.mkdir_p!(Path.dirname(module_file))
      File.write!(module_file, "defmodule Demo.Extensions.Dupe do\nend\n")

      assert_raise Mix.Error, ~r/File already exists/, fn ->
        Mix.Tasks.UnifiedUi.Gen.Extension.run_with(
          ["Demo.Extensions.Dupe", "--path", module_file, "--no-test"],
          fn _ -> :ok end
        )
      end
    end

    test "overwrites files when --force is provided" do
      root_path = unique_tmp_path()
      module_file = Path.join(root_path, "lib/demo/extensions/force.ex")
      File.mkdir_p!(Path.dirname(module_file))
      File.write!(module_file, "old contents\n")

      assert :ok =
               Mix.Tasks.UnifiedUi.Gen.Extension.run_with(
                 ["Demo.Extensions.Force", "--path", module_file, "--no-test", "--force"],
                 fn _ -> :ok end
               )

      refute File.read!(module_file) == "old contents\n"
      assert File.read!(module_file) =~ "defmodule Demo.Extensions.Force"
    end
  end

  defp unique_tmp_path do
    random = Base.encode16(:crypto.strong_rand_bytes(6), case: :lower)
    root_path = Path.join(System.tmp_dir!(), "unified_ui_gen_extension_task_#{random}")
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
