defmodule Mix.Tasks.UnifiedUi.New do
  @shortdoc "Scaffolds a new UnifiedUi project"
  @moduledoc """
  Generates a new UnifiedUi project skeleton with an example screen.

  The generated project includes:

  - mix project configuration
  - application supervision tree
  - example `HomeScreen` using `UnifiedUi.Dsl`
  - basic tests and formatter config

  ## Usage

      mix unified_ui.new my_app

  ## Options

  - `--path` - target directory path (defaults to app name)
  - `--force` - overwrite scaffold files if target directory exists
  """
  use Mix.Task

  @switches [path: :string, force: :boolean]

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
            "Unsupported options for mix unified_ui.new: #{inspect(invalid_opts)}. " <>
              "Supported options: --path, --force."
    end

    app_name =
      case positional do
        [name] ->
          validate_app_name!(name)

        [] ->
          raise Mix.Error, message: "Missing app name. Usage: mix unified_ui.new my_app [options]"

        _extra ->
          raise Mix.Error,
            message: "Expected exactly one app name. Usage: mix unified_ui.new my_app [options]"
      end

    project_path = opts[:path] || app_name
    force? = !!opts[:force]

    ensure_target!(project_path, force?)

    app_module = Macro.camelize(app_name)
    app_module_path = Macro.underscore(app_module)

    files = %{
      "mix.exs" => mix_exs_template(app_name, app_module),
      "config/config.exs" => config_template(),
      ".formatter.exs" => formatter_template(),
      ".gitignore" => gitignore_template(),
      "README.md" => readme_template(app_name, app_module),
      "lib/#{app_module_path}/application.ex" => application_template(app_module),
      "lib/#{app_module_path}/screens/home_screen.ex" => home_screen_template(app_module),
      "test/test_helper.exs" => "ExUnit.start()\n",
      "test/#{app_module_path}/screens/home_screen_test.exs" =>
        home_screen_test_template(app_module)
    }

    Enum.each(files, fn {relative_path, contents} ->
      write_file!(project_path, relative_path, contents, force?)
      output_fun.("Created #{relative_path}")
    end)

    output_fun.("Created project: #{Path.expand(project_path)}")
    output_fun.("Next steps: cd #{project_path} && mix deps.get")
    :ok
  end

  defp validate_app_name!(name) do
    if Regex.match?(~r/^[a-z][a-z0-9_]*$/, name) do
      name
    else
      raise Mix.Error,
        message: "Invalid app name: #{inspect(name)}. Expected snake_case like my_app."
    end
  end

  defp ensure_target!(project_path, force?) do
    if File.exists?(project_path) and not force? do
      raise Mix.Error,
        message: "Target path already exists: #{project_path}. Use --force to overwrite."
    else
      File.mkdir_p!(project_path)
    end
  end

  defp write_file!(project_path, relative_path, contents, force?) do
    absolute_path = Path.join(project_path, relative_path)

    case {File.exists?(absolute_path), force?} do
      {true, false} ->
        raise Mix.Error,
          message: "File already exists: #{absolute_path}. Use --force to overwrite."

      _ ->
        absolute_path |> Path.dirname() |> File.mkdir_p!()
        File.write!(absolute_path, contents)
    end
  end

  defp mix_exs_template(app_name, app_module) do
    """
    defmodule #{app_module}.MixProject do
      use Mix.Project

      def project do
        [
          app: :#{app_name},
          version: "0.1.0",
          elixir: "~> 1.18",
          start_permanent: Mix.env() == :prod,
          deps: deps()
        ]
      end

      def application do
        [
          extra_applications: [:logger],
          mod: {#{app_module}.Application, []}
        ]
      end

      defp deps do
        [
          {:unified_ui, "~> 0.1"},
          {:jido_signal, "~> 1.0"},
          {:spark, "~> 1.0"}
        ]
      end
    end
    """
  end

  defp config_template do
    """
    import Config
    """
  end

  defp formatter_template do
    """
    [
      inputs: [
        "{mix,.formatter}.exs",
        "{config,lib,test}/**/*.{ex,exs}"
      ]
    ]
    """
  end

  defp gitignore_template do
    """
    /_build/
    /deps/
    /cover/
    /.elixir_ls/
    erl_crash.dump
    """
  end

  defp readme_template(app_name, app_module) do
    """
    # #{app_module}

    Generated UnifiedUi project.

    ## Setup

    ```bash
    mix deps.get
    mix test
    ```

    ## Example Screen

    See `lib/#{app_name}/screens/home_screen.ex` for a starter screen built with `UnifiedUi.Dsl`.
    """
  end

  defp application_template(app_module) do
    """
    defmodule #{app_module}.Application do
      use Application

      @impl true
      def start(_type, _args) do
        children = [
          {Registry, keys: :unique, name: #{app_module}.AgentRegistry},
          {DynamicSupervisor, strategy: :one_for_one, name: #{app_module}.AgentSupervisor}
        ]

        Supervisor.start_link(children, strategy: :one_for_one, name: #{app_module}.Supervisor)
      end
    end
    """
  end

  defp home_screen_template(app_module) do
    """
    defmodule #{app_module}.Screens.HomeScreen do
      @behaviour UnifiedUi.ElmArchitecture
      use UnifiedUi.Dsl

      state count: 0

      ui do
        vbox id: :root, spacing: 1 do
          text "Welcome to #{app_module}"
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

  defp home_screen_test_template(app_module) do
    """
    defmodule #{app_module}.Screens.HomeScreenTest do
      use ExUnit.Case, async: true

      alias #{app_module}.Screens.HomeScreen

      test "init returns initial model state" do
        assert %{count: 0} = HomeScreen.init([])
      end

      test "view returns an IUR tree" do
        assert %{id: :root} = HomeScreen.view(%{count: 2})
      end
    end
    """
  end
end
