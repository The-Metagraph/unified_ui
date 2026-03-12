defmodule Mix.Tasks.UnifiedUi.Preview do
  @shortdoc "Renders a quick preview for a screen module"
  @moduledoc """
  Renders a quick preview for a screen module on one or more platforms.

  This task compiles a screen module by calling:

  - `init/1` (if available)
  - `view/1`
  - target renderer(s)

  ## Usage

      mix unified_ui.preview MyApp.Screens.HomeScreen

  ## Options

  - `--platform` - one of `terminal`, `desktop`, `web`, `all` (default: `terminal`)
  - `--web-output` - output path for generated web HTML preview (default: `tmp/unified_ui_preview.html`)
  - `--inspect` - print rendered root structures
  """
  use Mix.Task

  alias UnifiedUi.Adapters.{Terminal, Desktop, Web, Coordinator}

  @switches [platform: :string, web_output: :string, inspect: :boolean]
  @platforms [:terminal, :desktop, :web]

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
            "Unsupported options for mix unified_ui.preview: #{inspect(invalid_opts)}. " <>
              "Supported options: --platform, --web-output, --inspect."
    end

    module_name =
      case positional do
        [name] ->
          normalize_module_name!(name)

        [] ->
          raise Mix.Error,
            message:
              "Missing module name. Usage: mix unified_ui.preview MyApp.Screens.HomeScreen [options]"

        _extra ->
          raise Mix.Error,
            message:
              "Expected exactly one module name. Usage: mix unified_ui.preview MyApp.Screens.HomeScreen [options]"
      end

    module = Module.concat([module_name])

    unless Code.ensure_loaded?(module) do
      raise Mix.Error, message: "Module not found or not loaded: #{module_name}"
    end

    unless function_exported?(module, :view, 1) do
      raise Mix.Error, message: "Module #{module_name} must export view/1"
    end

    platform = parse_platform!(opts[:platform] || "terminal")
    web_output = opts[:web_output] || "tmp/unified_ui_preview.html"
    inspect? = !!opts[:inspect]

    state = initial_state(module)
    iur = module.view(state)

    if is_nil(iur) do
      raise Mix.Error, message: "Module #{module_name}.view/1 returned nil"
    end

    output_fun.("Preview module: #{module_name}")

    if inspect? do
      output_fun.("State: #{inspect(state, pretty: true)}")
      output_fun.("IUR: #{inspect(iur, pretty: true)}")
    end

    case platform do
      :all ->
        render_all(iur, web_output, inspect?, output_fun)

      platform ->
        render_one(iur, platform, web_output, inspect?, output_fun)
    end

    :ok
  end

  defp normalize_module_name!(name) do
    normalized =
      name
      |> String.trim()
      |> String.trim_leading("Elixir.")

    if Regex.match?(~r/^[A-Z]\w*(\.[A-Z]\w*)*$/, normalized) do
      normalized
    else
      raise Mix.Error,
        message:
          "Invalid module name: #{inspect(name)}. Expected alias format like MyApp.Screens.HomeScreen."
    end
  end

  defp parse_platform!(platform_string) do
    case platform_string do
      "terminal" -> :terminal
      "desktop" -> :desktop
      "web" -> :web
      "all" -> :all
      other -> raise Mix.Error, message: "Invalid --platform value: #{other}"
    end
  end

  defp initial_state(module) do
    if function_exported?(module, :init, 1) do
      module.init([])
      |> normalize_state(%{})
    else
      %{}
    end
  rescue
    _ -> %{}
  end

  defp normalize_state(%{} = state, _fallback), do: state
  defp normalize_state({:ok, %{} = state}, _fallback), do: state
  defp normalize_state({:noreply, %{} = state}, _fallback), do: state
  defp normalize_state(_other, fallback), do: fallback

  defp render_all(iur, web_output, inspect?, output_fun) do
    case Coordinator.render_on(iur, @platforms, []) do
      {:ok, results} ->
        Enum.each(@platforms, fn platform ->
          case Map.get(results, platform) do
            {:ok, state} ->
              output_fun.("Rendered #{platform} preview")
              maybe_output_root(platform, state, inspect?, output_fun)

            {:error, reason} ->
              output_fun.("Failed #{platform} preview: #{inspect(reason)}")
          end
        end)

        maybe_write_web_output(Map.get(results, :web), web_output, output_fun)

      {:error, reason} ->
        raise Mix.Error, message: "Preview rendering failed: #{inspect(reason)}"
    end
  end

  defp render_one(iur, platform, web_output, inspect?, output_fun) do
    renderer = renderer_for(platform)

    case renderer.render(iur, []) do
      {:ok, state} ->
        output_fun.("Rendered #{platform} preview")
        maybe_output_root(platform, state, inspect?, output_fun)

        if platform == :web do
          maybe_write_web_output({:ok, state}, web_output, output_fun)
        end

      other ->
        raise Mix.Error,
          message: "Preview rendering failed for #{platform}: #{inspect(other)}"
    end
  end

  defp renderer_for(:terminal), do: Terminal
  defp renderer_for(:desktop), do: Desktop
  defp renderer_for(:web), do: Web

  defp maybe_output_root(_platform, _state, false, _output_fun), do: :ok

  defp maybe_output_root(platform, state, true, output_fun) do
    output_fun.("#{platform} root: #{inspect(state.root, pretty: true)}")
  end

  defp maybe_write_web_output({:ok, state}, web_output, output_fun) when is_binary(state.root) do
    web_output |> Path.dirname() |> File.mkdir_p!()
    File.write!(web_output, state.root)
    output_fun.("Wrote web preview HTML: #{Path.expand(web_output)}")
  end

  defp maybe_write_web_output(_result, _web_output, _output_fun), do: :ok
end
