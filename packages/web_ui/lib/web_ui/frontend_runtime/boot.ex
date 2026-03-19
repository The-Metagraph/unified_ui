defmodule WebUi.FrontendRuntime.Boot do
  @moduledoc """
  Frontend boot process for web_ui Elm runtime.

  This module handles the server-side responsibilities for booting
  the Elm frontend, including asset compilation and initial hydration.
  """

  require Phoenix.HTML

  alias WebUi.ServerRuntime.State

  @type boot_config :: %{
          assets_path: String.t(),
          elm_module: String.t(),
          debug_mode: boolean()
        }

  @type hydration_state :: %{
          schema: map(),
          version: String.t(),
          assigns: map(),
          checksum: String.t()
        }

  @doc """
  Returns the default boot configuration.
  """
  @spec default_config() :: boot_config()
  def default_config do
    %{
      assets_path: "/assets/js",
      elm_module: "WebUi.Elm",
      debug_mode: false
    }
  end

  @doc """
  Prepares the hydration state for the Elm frontend.
  """
  @spec prepare_hydration(State.t()) :: hydration_state()
  def prepare_hydration(%State{} = state) do
    State.frontend_state(state)
  end

  @doc """
  Generates the Elm boot script tag for HTML.
  """
  @spec elm_script_tag(boot_config()) :: Phoenix.HTML.safe()
  def elm_script_tag(config \\ default_config()) do
    src = "#{config.assets_path}/#{config.elm_module}.js"
    {:safe, "<script src=\"#{src}\"></script>"}
  end

  @doc """
  Generates the hydration data script for Elm.
  """
  @spec hydration_script_tag(hydration_state(), String.t()) :: Phoenix.HTML.safe()
  def hydration_script_tag(hydration_state, element_id \\ "app") do
    json = Jason.encode_to_iodata!(hydration_state)

    script_content = """
    window.WebUiHydration = window.WebUiHydration || {};
    window.WebUiHydration["#{element_id}"] = #{json};
    """

    {:safe, "<script data-phx-main data-elm-#{element_id}>#{script_content}</script>"}
  end

  @doc """
  Returns the Elm entrypoint initialization flags.
  """
  @spec elm_init_flags(hydration_state()) :: map()
  def elm_init_flags(hydration_state) do
    %{
      hydration: hydration_state,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    }
  end

  @doc """
  Validates that the Elm assets are available.
  """
  @spec validate_assets(boot_config()) :: :ok | {:error, atom()}
  def validate_assets(_config) do
    # Check if Elm assets are compiled
    # This is a placeholder - actual implementation would check file existence
    :ok
  end
end
