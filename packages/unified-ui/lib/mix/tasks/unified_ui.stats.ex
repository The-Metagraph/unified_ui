defmodule Mix.Tasks.UnifiedUi.Stats do
  @shortdoc "Shows UnifiedUi project statistics"
  @moduledoc """
  Shows project statistics for a UnifiedUi codebase.

  By default this task inspects the current working directory.

  ## Options

  - `--path` - project path to inspect (defaults to current working directory)
  """
  use Mix.Task

  @switches [path: :string]

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(args) do
    run_with(args, fn line -> Mix.shell().info(line) end)
  end

  @doc false
  @spec run_with([String.t()], (String.t() -> any())) :: :ok
  def run_with(args, output_fun) when is_function(output_fun, 1) do
    {opts, _remaining_args, invalid} = OptionParser.parse(args, strict: @switches)

    case invalid do
      [] ->
        :ok

      invalid_opts ->
        raise Mix.Error,
          message:
            "Unsupported options for mix unified_ui.stats: #{inspect(invalid_opts)}. " <>
              "Supported options: --path."
    end

    root_path =
      opts[:path]
      |> Kernel.||(File.cwd!())
      |> Path.expand()

    root_path
    |> collect_stats()
    |> render_stats(root_path)
    |> Enum.each(output_fun)

    :ok
  end

  defp collect_stats(root_path) do
    lib_files = wildcard(root_path, "lib/**/*.ex")
    test_files = wildcard(root_path, "test/**/*_test.exs")
    mix_task_files = wildcard(root_path, "lib/mix/tasks/unified_ui*.ex")
    guide_files = wildcard(root_path, "guides/**/*.md")
    elixir_files = lib_files ++ wildcard(root_path, "test/**/*.exs")

    %{
      module_count: count_modules(lib_files),
      lib_file_count: length(lib_files),
      test_file_count: length(test_files),
      mix_task_count: length(mix_task_files),
      guide_file_count: length(guide_files),
      elixir_loc: count_lines(elixir_files)
    }
  end

  defp render_stats(stats, root_path) do
    [
      "UnifiedUi Project Statistics",
      "Path: #{root_path}",
      "Library modules: #{stats.module_count}",
      "Library files: #{stats.lib_file_count}",
      "Test files: #{stats.test_file_count}",
      "Mix tasks: #{stats.mix_task_count}",
      "Guide files: #{stats.guide_file_count}",
      "Elixir LOC (lib + test): #{stats.elixir_loc}"
    ]
  end

  defp wildcard(root_path, pattern) do
    root_path
    |> Path.join(pattern)
    |> Path.wildcard()
  end

  defp count_modules(files) do
    Enum.reduce(files, 0, fn file_path, acc ->
      case File.read(file_path) do
        {:ok, contents} ->
          acc + length(Regex.scan(~r/^\s*defmodule\s+/m, contents))

        {:error, _reason} ->
          acc
      end
    end)
  end

  defp count_lines(files) do
    Enum.reduce(files, 0, fn file_path, acc ->
      case File.read(file_path) do
        {:ok, contents} ->
          acc + line_count(contents)

        {:error, _reason} ->
          acc
      end
    end)
  end

  defp line_count(""), do: 0

  defp line_count(contents) do
    newline_count = length(:binary.matches(contents, "\n"))
    trailing_line = if String.ends_with?(contents, "\n"), do: 0, else: 1

    newline_count + trailing_line
  end
end
