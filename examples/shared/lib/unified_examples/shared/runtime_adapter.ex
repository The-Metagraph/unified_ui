defmodule UnifiedExamples.Shared.RuntimeAdapter do
  @moduledoc """
  Runtime adapter that dispatches to the configured UI package (live_ui, desktop_ui, etc.)
  based on configuration or CLI flag override.
  """

  @doc """
  Get the configured runtime module based on:
  1. CLI flag override (--runtime)
  2. Environment variable (UNIFIED_RUNTIME)
  3. Config file setting (config :unified_examples, :runtime)
  4. Default fallback (live_ui)
  """
  @spec runtime_module() :: atom()
  def runtime_module do
    # 1. CLI flag override (set in Application config during boot)
    cli_runtime = Application.get_env(:unified_examples_shared, :cli_runtime)

    # 2. Environment variable
    env_runtime = System.get_env("UNIFIED_RUNTIME")

    # 3. Config file
    config_runtime = Application.get_env(:unified_examples_shared, :runtime)

    # 4. Default fallback
    runtime_option = cli_runtime || env_runtime || config_runtime || :live_ui
    parse_runtime_option(runtime_option)
  end

  @doc """
  Parse runtime option string into module atom.
  Supports: "live_ui", "desktop_ui", "live", "desktop" (aliases)
  """
  @spec parse_runtime_option(String.t() | atom()) :: atom()
  def parse_runtime_option(option) when is_atom(option), do: parse_runtime_option(to_string(option))

  def parse_runtime_option("live_ui"), do: LiveUi.Runtime
  def parse_runtime_option("live"), do: LiveUi.Runtime
  def parse_runtime_option("desktop_ui"), do: DesktopUi.Runtime
  def parse_runtime_option("desktop"), do: DesktopUi.Runtime
  def parse_runtime_option(option) when is_binary(option) do
    sanitized = String.downcase(option) |> String.replace("-", "_")
    case sanitized do
      "live" <> _ -> LiveUi.Runtime
      "desktop" <> _ -> DesktopUi.Runtime
      _ ->
        raise ArgumentError, """
        Unknown runtime option: #{option}

        Supported options:
          - live_ui (or "live")
          - desktop_ui (or "desktop")

        You can also:
          1. Set UNIFIED_RUNTIME environment variable
          2. Configure :runtime in :unified_examples_shared config
          3. Use --runtime flag when launching examples
        """
    end
  end

  @doc """
  Mount an IUR element using the configured runtime.

  ## Examples

      iex> RuntimeAdapter.mount_iur(element)
      {:ok, %LiveUi.Runtime.State{}}

      iex> RuntimeAdapter.mount_iur(element, runtime: :desktop_ui)
      {:ok, %DesktopUi.Runtime.State{}}
  """
  @spec mount_iur(UnifiedIUR.Element.t(), keyword()) :: {:ok, struct()} | {:error, term()}
  def mount_iur(element, opts \\ []) do
    runtime = Keyword.get(opts, :runtime, runtime_module())
    runtime.mount_iur(element, opts)
  end

  @doc """
  Get the component module for the configured runtime.

  Used to render HTML (LiveView) or other output formats.
  """
  @spec component_module() :: module()
  def component_module do
    case runtime_module() do
      LiveUi.Runtime -> LiveUi.Runtime.component()
      DesktopUi.Runtime -> DesktopUi.Runtime.component()
      # Add other runtimes here as needed
    end
  end

  @doc """
  Get the tooling/inspection module for the configured runtime.
  """
  @spec tooling_module() :: module()
  def tooling_module do
    case runtime_module() do
      LiveUi.Runtime -> LiveUi.Tooling
      DesktopUi.Runtime -> DesktopUi.Tooling
      # Add other runtimes here as needed
    end
  end

  @doc """
  Check if the configured runtime is available/loaded.
  """
  @spec runtime_available?() :: boolean()
  def runtime_available? do
    case runtime_module() do
      LiveUi.Runtime -> Code.ensure_loaded?(LiveUi.Runtime)
      DesktopUi.Runtime -> Code.ensure_loaded?(DesktopUi.Runtime)
      _ -> false
    end
  end

  @doc """
  Get a descriptive name for the configured runtime.
  """
  @spec runtime_name() :: String.t()
  def runtime_name do
    case runtime_module() do
      LiveUi.Runtime -> "LiveView (browser)"
      DesktopUi.Runtime -> "Desktop UI (native)"
      :live_ui -> "LiveView (browser)"
      :desktop_ui -> "Desktop UI (native)"
      _ -> "Unknown Runtime"
    end
  end

  @doc """
  List all available runtimes.
  """
  @spec available_runtimes() :: [{atom(), String.t()}, ...]
  def available_runtimes do
    [
      {:live_ui, "LiveView (browser)"},
      {:desktop_ui, "Desktop UI (native)"}
    ]
  end

  @doc """
  Validate that the configured runtime is available.
  Raises an error if the runtime module is not loaded.
  """
  @spec validate_runtime!() :: :ok | no_return
  def validate_runtime! do
    unless runtime_available?() do
      raise RuntimeError, """
      Configured runtime is not available: #{runtime_module()}

      Available runtimes: #{inspect(available_runtimes(), pretty: true)}

      To fix this, either:
      1. Add the runtime package to dependencies
      2. Change the configured runtime via:
         - Config: config :unified_examples_shared, :runtime, :desktop_ui
         - Environment: UNIFIED_RUNTIME=desktop_ui
      """
    end

    :ok
  end
end
