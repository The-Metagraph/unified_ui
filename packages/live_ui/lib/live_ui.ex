defmodule LiveUi do
  @moduledoc """
  Public helpers for the `live_ui` host integration surface.

  Hosts can integrate the library in three ways:

  - compose screens directly from `LiveUi.Widgets`
  - mount canonical `UnifiedIUR` through `LiveUi.Live.DynamicLive`
  - declare thin wrapper LiveViews around source modules with `LiveUi.Screen`

  `LiveUi.Live.DynamicLive` expects a session envelope produced by
  `dynamic_session/2` or `dynamic_iur_session/2`.
  """

  alias LiveUi.ConfigurationError

  @dynamic_session_key "live_ui_dynamic"

  @type runtime_context :: map()
  @type source_module :: module()
  @type dynamic_session_option ::
          {:context, runtime_context()}
          | {:source_opts, keyword()}

  @spec dynamic_session_key() :: String.t()
  def dynamic_session_key, do: @dynamic_session_key

  @doc """
  Builds the session envelope consumed by `LiveUi.Live.DynamicLive`.
  """
  @spec dynamic_session(source_module(), [dynamic_session_option()]) :: map()
  def dynamic_session(source_module, opts \\ []) when is_list(opts) do
    %{
      dynamic_session_key() => %{
        "source" => source_module,
        "source_opts" => Keyword.get(opts, :source_opts, []),
        "context" => Keyword.get(opts, :context, %{})
      }
    }
  end

  @doc """
  Builds the session envelope for mounting a canonical raw IUR payload through
  `LiveUi.Live.DynamicLive`.
  """
  @spec dynamic_iur_session(term(), [dynamic_session_option()]) :: map()
  def dynamic_iur_session(iur_tree, opts \\ []) when is_list(opts) do
    %{
      dynamic_session_key() => %{
        "iur" => iur_tree,
        "context" => Keyword.get(opts, :context, %{})
      }
    }
  end

  @doc """
  Extracts the normalized dynamic session configuration from a LiveView session.
  """
  @spec fetch_dynamic_session(map()) :: {:ok, map()} | {:error, ConfigurationError.t()}
  def fetch_dynamic_session(session) when is_map(session) do
    case Map.get(session, dynamic_session_key()) || Map.get(session, :live_ui_dynamic) do
      %{} = config -> {:ok, config}
      _ -> {:error, ConfigurationError.new("missing dynamic live_ui session configuration")}
    end
  end

  def fetch_dynamic_session(_session) do
    {:error, ConfigurationError.new("live_ui dynamic session must be a map")}
  end
end
