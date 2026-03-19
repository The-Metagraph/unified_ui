defmodule WebUi.ServerRuntime.BrowserBridge do
  @moduledoc """
  Server-side browser bridge coordination for web_ui.

  This module provides the server-side coordination for browser
  interactions, maintaining the server-authoritative model while
  allowing controlled client-side interactivity.
  """

  alias WebUi.ServerRuntime.{Channel, Error}

  @type hook :: atom()

  @supported_hooks [
    :resize_observer,
    :viewport_measurement,
    :scroll_tracking,
    :form_interaction,
    :navigation
  ]

  @type bridge_state :: %{
          hooks: [hook()],
          enabled_features: MapSet.t(atom()),
          sync_interval: pos_integer() | nil
        }

  @doc """
  Returns the list of supported browser bridge hooks.
  """
  @spec supported_hooks() :: [hook()]
  def supported_hooks, do: @supported_hooks

  @doc """
  Initializes a new bridge state.
  """
  @spec init(keyword()) :: bridge_state()
  def init(opts \\ []) do
    hooks = Keyword.get(opts, :hooks, [])
    enabled_features = Keyword.get(opts, :enabled_features, MapSet.new())
    sync_interval = Keyword.get(opts, :sync_interval, nil)

    %{
      hooks: normalize_hooks(hooks),
      enabled_features: MapSet.new(enabled_features),
      sync_interval: sync_interval
    }
  end

  @doc """
  Normalizes a list of hooks, removing duplicates and filtering unsupported hooks.
  """
  @spec normalize_hooks([hook()]) :: [hook()]
  def normalize_hooks(hooks) when is_list(hooks) do
    hooks
    |> Enum.uniq()
    |> Enum.filter(&supported?/1)
  end

  @doc """
  Checks if a hook is supported.
  """
  @spec supported?(hook()) :: boolean()
  def supported?(hook) when is_atom(hook), do: hook in @supported_hooks

  @doc """
  Checks if runtime authority is maintained (always true for web_ui).
  """
  @spec authoritative?() :: boolean()
  def authoritative?, do: true

  @doc """
  Normalizes a browser event payload into a message envelope.
  """
  @spec normalize_browser_event(String.t(), map(), bridge_state()) ::
          {:ok, Channel.message_envelope()} | {:error, Error.t()}
  def normalize_browser_event(event_type, payload, _bridge_state)
      when is_binary(event_type) and is_map(payload) do
    {:ok, Channel.envelope(event_type, payload)}
  end

  def normalize_browser_event(_event_type, _payload, _bridge_state) do
    {:error, Error.hydration_failed(nil, :invalid_browser_event)}
  end

  @doc """
  Validates bridge state consistency.
  """
  @spec validate_state(bridge_state()) :: :ok | {:error, atom()}
  def validate_state(%{hooks: hooks, enabled_features: _features, sync_interval: _interval})
      when is_list(hooks) do
    :ok
  end

  def validate_state(_), do: {:error, :invalid_bridge_state}

  @doc """
  Returns the configured sync interval.
  """
  @spec sync_interval(bridge_state()) :: pos_integer() | nil
  def sync_interval(%{sync_interval: interval}), do: interval

  @doc """
  Checks if a feature is enabled.
  """
  @spec feature_enabled?(bridge_state(), atom()) :: boolean()
  def feature_enabled?(%{enabled_features: features}, feature) when is_atom(feature) do
    MapSet.member?(features, feature)
  end

  @doc """
  Enables a feature in the bridge state.
  """
  @spec enable_feature(bridge_state(), atom()) :: bridge_state()
  def enable_feature(%{enabled_features: features} = bridge_state, feature) when is_atom(feature) do
    %{bridge_state | enabled_features: MapSet.put(features, feature)}
  end

  @doc """
  Disables a feature in the bridge state.
  """
  @spec disable_feature(bridge_state(), atom()) :: bridge_state()
  def disable_feature(%{enabled_features: features} = bridge_state, feature) when is_atom(feature) do
    %{bridge_state | enabled_features: MapSet.delete(features, feature)}
  end
end
