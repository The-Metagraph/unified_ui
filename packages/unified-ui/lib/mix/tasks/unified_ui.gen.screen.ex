defmodule Mix.Tasks.UnifiedUi.Gen.Screen do
  @shortdoc "Generates a UnifiedUi screen module and optional test"
  @moduledoc """
  Generates a UnifiedUi screen module using the Elm Architecture pattern.

  By default this task creates:

  - a screen module in `lib/`
  - a matching test module in `test/`
  - a UnifiedUi.Agent.Server child spec entry in your application supervisor

  ## Usage

      mix unified_ui.gen.screen MyApp.CounterScreen

  ## Options

  - `--path` - output path for the generated module (directory or `.ex` file path)
  - `--test-path` - output path for generated test (directory or `_test.exs` file path)
  - `--supervisor-file` - application/supervisor file to update (defaults to app `application.ex`)
  - `--component-id` - component id atom name without `:` (defaults from module name)
  - `--no-test` - skip test generation
  - `--no-supervisor` - skip supervisor file update
  - `--force` - overwrite existing generated files
  """
  use Mix.Task

  @switches [
    path: :string,
    test_path: :string,
    supervisor_file: :string,
    component_id: :string,
    no_test: :boolean,
    no_supervisor: :boolean,
    force: :boolean
  ]

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(args) do
    run_with(args, fn line -> Mix.shell().info(line) end)
  end

  @doc false
  @spec run_with([String.t()], (String.t() -> any())) :: :ok
  def run_with(args, output_fun) when is_function(output_fun, 1) do
    {opts, positional, invalid} = OptionParser.parse(args, strict: @switches)

    case invalid do
      [] ->
        :ok

      invalid_opts ->
        raise Mix.Error,
          message:
            "Unsupported options for mix unified_ui.gen.screen: #{inspect(invalid_opts)}. " <>
              "Supported options: --path, --test-path, --supervisor-file, --component-id, " <>
              "--no-test, --no-supervisor, --force."
    end

    module_name =
      case positional do
        [name] ->
          validate_module_name!(name)

        [] ->
          raise Mix.Error,
            message:
              "Missing module name. Usage: mix unified_ui.gen.screen MyApp.CounterScreen [options]"

        _extra ->
          raise Mix.Error,
            message:
              "Expected exactly one module name. Usage: mix unified_ui.gen.screen MyApp.CounterScreen [options]"
      end

    module_file = module_file_path(module_name, opts[:path])
    test_file = test_file_path(module_name, opts[:test_path])
    force? = !!opts[:force]
    component_id = normalized_component_id(module_name, opts[:component_id])

    write_file!(module_file, screen_template(module_name), force?)
    output_fun.("Created screen: #{module_file}")

    unless opts[:no_test] do
      write_file!(test_file, screen_test_template(module_name), force?)
      output_fun.("Created test: #{test_file}")
    end

    unless opts[:no_supervisor] do
      supervisor_file = opts[:supervisor_file] || default_supervisor_file()

      case add_screen_child(supervisor_file, module_name, component_id) do
        :added ->
          output_fun.("Updated supervisor: #{supervisor_file}")

        :already_present ->
          output_fun.("Supervisor already contains child for #{module_name}: #{supervisor_file}")

        {:error, reason} ->
          raise Mix.Error,
            message: "Failed to update supervisor file #{supervisor_file}: #{reason}"
      end
    end

    :ok
  end

  defp validate_module_name!(name) do
    if Regex.match?(~r/^[A-Z]\w*(\.[A-Z]\w*)*$/, name) do
      name
    else
      raise Mix.Error,
        message:
          "Invalid module name: #{inspect(name)}. Expected alias format like MyApp.CounterScreen."
    end
  end

  defp module_file_path(module_name, nil) do
    module_name
    |> Macro.underscore()
    |> then(&Path.join("lib", "#{&1}.ex"))
  end

  defp module_file_path(module_name, path) do
    if String.ends_with?(path, ".ex") do
      path
    else
      module_basename = module_name |> module_basename() |> Kernel.<>(".ex")
      Path.join(path, module_basename)
    end
  end

  defp test_file_path(module_name, nil) do
    module_name
    |> Macro.underscore()
    |> then(&Path.join("test", "#{&1}_test.exs"))
  end

  defp test_file_path(module_name, path) do
    if String.ends_with?(path, "_test.exs") do
      path
    else
      module_basename = module_name |> module_basename() |> Kernel.<>("_test.exs")
      Path.join(path, module_basename)
    end
  end

  defp module_basename(module_name) do
    module_name
    |> String.split(".")
    |> List.last()
    |> Macro.underscore()
  end

  defp module_alias_basename(module_name) do
    module_name
    |> String.split(".")
    |> List.last()
  end

  defp normalized_component_id(module_name, nil), do: module_basename(module_name)

  defp normalized_component_id(_module_name, component_id) do
    component_id
    |> String.trim()
    |> String.trim_leading(":")
  end

  defp default_supervisor_file do
    app_name =
      Mix.Project.config()
      |> Keyword.fetch!(:app)
      |> to_string()

    Path.join(["lib", app_name, "application.ex"])
  end

  defp write_file!(path, contents, force?) do
    case {File.exists?(path), force?} do
      {true, false} ->
        raise Mix.Error,
          message: "File already exists: #{path}. Use --force to overwrite."

      _ ->
        path |> Path.dirname() |> File.mkdir_p!()
        File.write!(path, contents)
    end
  end

  defp add_screen_child(supervisor_file, module_name, component_id) do
    child_spec =
      "{UnifiedUi.Agent.Server, module: #{module_name}, component_id: :#{component_id}}"

    case File.read(supervisor_file) do
      {:ok, contents} ->
        if String.contains?(contents, "module: #{module_name}") do
          :already_present
        else
          case Regex.run(~r/children\s*=\s*\[/, contents, return: :index) do
            [{start, len}] ->
              insert_at = start + len
              {prefix, suffix} = binary_split_at(contents, insert_at)
              updated = prefix <> "\n      #{child_spec}," <> suffix
              File.write!(supervisor_file, updated)
              :added

            _ ->
              {:error, "could not find `children = [` list"}
          end
        end

      {:error, reason} ->
        {:error,
         Exception.message(
           File.Error.exception(reason: reason, action: "read", path: supervisor_file)
         )}
    end
  end

  defp binary_split_at(binary, index) do
    prefix = binary_part(binary, 0, index)
    suffix = binary_part(binary, index, byte_size(binary) - index)
    {prefix, suffix}
  end

  defp screen_template(module_name) do
    """
    defmodule #{module_name} do
      @behaviour UnifiedUi.ElmArchitecture
      use UnifiedUi.Dsl

      state count: 0

      ui do
        vbox id: :root, spacing: 1 do
          text "Count: \#{state.count}"

          hbox spacing: 1 do
            button "Increment", on_click: :increment
            button "Decrement", on_click: :decrement
          end
        end
      end

      @impl true
      def init(_opts), do: %{count: 0}

      @impl true
      def update(state, %Jido.Signal{data: %{action: :increment}}) do
        {:ok, %{state | count: state.count + 1}}
      end

      def update(state, %Jido.Signal{data: %{action: :decrement}}) do
        {:ok, %{state | count: state.count - 1}}
      end

      def update(state, _signal), do: {:ok, state}
    end
    """
  end

  defp screen_test_template(module_name) do
    alias_basename = module_alias_basename(module_name)

    """
    defmodule #{module_name}Test do
      use ExUnit.Case, async: true

      alias #{module_name}

      test "init returns initial state" do
        assert %{count: 0} = #{alias_basename}.init([])
      end

      test "view returns an IUR tree" do
        assert %{id: :root} = #{alias_basename}.view(%{count: 1})
      end
    end
    """
  end
end
